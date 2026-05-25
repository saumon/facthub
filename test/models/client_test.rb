require "test_helper"

class ClientTest < ActiveSupport::TestCase
  setup do
    Client.delete_all
  end

  test "client is created with a generated client_identifier" do
    client = Client.create!
    assert_not_nil client.client_identifier
    assert_not_empty client.client_identifier
  end

  test "client_identifier is unique across clients" do
    c1 = Client.create!
    c2 = Client.create!
    assert_not_equal c1.client_identifier, c2.client_identifier
  end

  test "client_identifier cannot be blank" do
    client = Client.new(client_identifier: "")
    # Bypass the before_create callback to test the validation directly
    client.client_identifier = ""
    assert_not client.valid?
    assert_includes client.errors[:client_identifier], "can't be blank"
  end

  test "client_identifier must be unique (validation)" do
    c1 = Client.create!
    c2 = Client.new
    c2.client_identifier = c1.client_identifier
    assert_not c2.valid?
    assert_includes c2.errors[:client_identifier], "has already been taken"
  end

  test "new client has nil last_fact_id" do
    client = Client.create!
    assert_nil client.last_fact_id
  end

  test "reset_progression! sets last_fact_id back to nil" do
    client = Client.create!
    client.update!(last_fact_id: 42)
    client.reset_progression!
    client.reload
    assert_nil client.last_fact_id
  end

  test "deleted client is no longer resolvable by identifier" do
    client = Client.create!
    identifier = client.client_identifier
    client.destroy
    assert_nil Client.find_by(client_identifier: identifier)
  end

  # ---------------------------------------------------------------------------
  # Alias normalization
  # ---------------------------------------------------------------------------

  test "alias is trimmed before validation and persistence" do
    client = Client.new(alias: "  Hello  ")
    client.valid?
    assert_equal "Hello", client.alias
  end

  test "whitespace-only alias is treated as empty and stored as nil" do
    client = Client.new(alias: "   ")
    client.valid?
    assert_nil client.alias
  end

  test "blank alias is stored as nil" do
    client = Client.new(alias: "")
    client.valid?
    assert_nil client.alias
  end

  test "nil alias remains nil" do
    client = Client.new
    client.valid?
    assert_nil client.alias
  end

  test "internal whitespace is preserved" do
    client = Client.new(alias: "  Operations West  ")
    client.valid?
    assert_equal "Operations West", client.alias
  end

  # ---------------------------------------------------------------------------
  # Alias validation
  # ---------------------------------------------------------------------------

  test "alias trimmed length of exactly 100 characters is valid" do
    client = Client.new(alias: "a" * 100)
    assert client.valid?
  end

  test "alias trimmed length over 100 characters is invalid" do
    client = Client.new(alias: "a" * 101)
    assert_not client.valid?
    assert_includes client.errors[:alias], "is too long (maximum is 100 characters)"
  end

  test "duplicate aliases across clients are allowed" do
    Client.create!(alias: "Shared Alias")
    c2 = Client.new(alias: "Shared Alias")
    assert c2.valid?
  end

  # ---------------------------------------------------------------------------
  # Alias and reset_progression!
  # ---------------------------------------------------------------------------

  test "reset_progression! does not affect alias" do
    client = Client.create!(alias: "Team Alpha")
    client.update!(last_fact_id: 42)
    client.reset_progression!
    client.reload
    assert_equal "Team Alpha", client.alias
    assert_nil client.last_fact_id
  end
end
