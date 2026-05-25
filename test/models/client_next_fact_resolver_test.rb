require "test_helper"

class ClientNextFactResolverTest < ActiveSupport::TestCase
  setup do
    Fact.delete_all
    Client.delete_all
  end

  test "returns nil when no facts exist" do
    client = Client.create!
    result = ClientNextFactResolver.new(client).call
    assert_nil result
  end

  test "returns the first fact when client has no cursor" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    client = Client.create!
    result = ClientNextFactResolver.new(client).call
    assert_equal f1.id, result.id
  end

  test "advances cursor in ascending id order" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    f3 = Fact.create!(body: "Fact C")
    client = Client.create!

    r1 = ClientNextFactResolver.new(client).call
    r2 = ClientNextFactResolver.new(client).call
    r3 = ClientNextFactResolver.new(client).call

    assert_equal f1.id, r1.id
    assert_equal f2.id, r2.id
    assert_equal f3.id, r3.id
  end

  test "wraps around to the first fact after the last fact" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    client = Client.create!

    ClientNextFactResolver.new(client).call # → f1
    ClientNextFactResolver.new(client).call # → f2
    result = ClientNextFactResolver.new(client).call # → wrap to f1
    assert_equal f1.id, result.id
  end

  test "skips deleted facts and continues from next available id" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    f3 = Fact.create!(body: "Fact C")
    client = Client.create!

    ClientNextFactResolver.new(client).call # → f1
    f2.destroy

    result = ClientNextFactResolver.new(client).call # → skips f2, returns f3
    assert_equal f3.id, result.id
  end

  test "wraps when cursor points to the last deleted fact" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    client = Client.create!

    ClientNextFactResolver.new(client).call # → f1
    ClientNextFactResolver.new(client).call # → f2
    f1.reload rescue nil # f1 still present
    # cursor is now at f2 (the last one); next call should wrap to f1
    result = ClientNextFactResolver.new(client).call
    assert_equal f1.id, result.id
  end

  test "cursor is stored after each call" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    client = Client.create!

    ClientNextFactResolver.new(client).call
    client.reload
    assert_equal f1.id, client.last_fact_id

    ClientNextFactResolver.new(client).call
    client.reload
    assert_equal f2.id, client.last_fact_id
  end

  test "cursor stays nil after a no-facts call" do
    client = Client.create!
    ClientNextFactResolver.new(client).call
    client.reload
    assert_nil client.last_fact_id
  end

  test "each client has independent cursor" do
    f1 = Fact.create!(body: "Fact A")
    f2 = Fact.create!(body: "Fact B")
    client_a = Client.create!
    client_b = Client.create!

    ClientNextFactResolver.new(client_a).call # → f1
    result_b = ClientNextFactResolver.new(client_b).call # → f1 (independent)
    assert_equal f1.id, result_b.id
  end
end
