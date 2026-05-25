require "test_helper"

class Admin::ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
    sign_in @admin
    @client = clients(:alice)
  end

  # ---------------------------------------------------------------------------
  # Auth guard
  # ---------------------------------------------------------------------------

  test "index redirects when not signed in" do
    sign_out @admin
    get admin_clients_path
    assert_redirected_to new_admin_session_path
  end

  test "show redirects when not signed in" do
    sign_out @admin
    get admin_client_path(@client)
    assert_redirected_to new_admin_session_path
  end

  test "new redirects when not signed in" do
    sign_out @admin
    get new_admin_client_path
    assert_redirected_to new_admin_session_path
  end

  test "create redirects when not signed in" do
    sign_out @admin
    post admin_clients_path, params: { client: { alias: "" } }
    assert_redirected_to new_admin_session_path
  end

  test "reset redirects when not signed in" do
    sign_out @admin
    post reset_admin_client_path(@client)
    assert_redirected_to new_admin_session_path
  end

  test "destroy redirects when not signed in" do
    sign_out @admin
    delete admin_client_path(@client)
    assert_redirected_to new_admin_session_path
  end

  test "update redirects when not signed in" do
    sign_out @admin
    patch admin_client_path(@client), params: { client: { alias: "Test" } }
    assert_redirected_to new_admin_session_path
  end

  # ---------------------------------------------------------------------------
  # Authenticated flows
  # ---------------------------------------------------------------------------

  test "index returns 200 with client list" do
    get admin_clients_path
    assert_response :success
  end

  test "show returns 200 for existing client" do
    get admin_client_path(@client)
    assert_response :success
  end

  test "new returns 200" do
    get new_admin_client_path
    assert_response :success
  end

  test "create creates a client and redirects to show" do
    assert_difference "Client.count", 1 do
      post admin_clients_path, params: { client: { alias: "" } }
    end
    created = Client.order(:created_at).last
    assert_redirected_to admin_client_path(created)
    follow_redirect!
    assert_response :success
  end

  test "created client has a generated client_identifier" do
    post admin_clients_path, params: { client: { alias: "" } }
    created = Client.order(:created_at).last
    assert_not_nil created.client_identifier
    assert_not_empty created.client_identifier
  end

  test "reset sets last_fact_id to nil and redirects to show" do
    @client.update!(last_fact_id: 99)
    post reset_admin_client_path(@client)
    @client.reload
    assert_nil @client.last_fact_id
    assert_redirected_to admin_client_path(@client)
  end

  test "destroy removes the client and redirects to index" do
    assert_difference "Client.count", -1 do
      delete admin_client_path(@client)
    end
    assert_redirected_to admin_clients_path
  end

  # ---------------------------------------------------------------------------
  # T007 – Create with alias (US1)
  # ---------------------------------------------------------------------------

  test "create with alias saves the alias" do
    post admin_clients_path, params: { client: { alias: "Test Alias" } }
    created = Client.order(:created_at).last
    assert_equal "Test Alias", created.alias
  end

  test "create trims alias whitespace on save" do
    post admin_clients_path, params: { client: { alias: "  Trimmed Alias  " } }
    created = Client.order(:created_at).last
    assert_equal "Trimmed Alias", created.alias
  end

  test "create with blank alias creates client with nil alias" do
    post admin_clients_path, params: { client: { alias: "" } }
    created = Client.order(:created_at).last
    assert_nil created.alias
  end

  test "create with whitespace-only alias creates client with nil alias" do
    post admin_clients_path, params: { client: { alias: "   " } }
    created = Client.order(:created_at).last
    assert_nil created.alias
  end

  test "create with oversized alias re-renders new form with 422" do
    assert_no_difference "Client.count" do
      post admin_clients_path, params: { client: { alias: "a" * 101 } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # T013 – Alias update (US2)
  # ---------------------------------------------------------------------------

  test "update patches client alias and redirects to show" do
    patch admin_client_path(@client), params: { client: { alias: "Updated Alias" } }
    @client.reload
    assert_equal "Updated Alias", @client.alias
    assert_redirected_to admin_client_path(@client)
  end

  test "update trims alias whitespace" do
    patch admin_client_path(@client), params: { client: { alias: "  Trimmed  " } }
    @client.reload
    assert_equal "Trimmed", @client.alias
  end

  test "update with blank alias clears alias to nil" do
    @client.update!(alias: "Existing Alias")
    patch admin_client_path(@client), params: { client: { alias: "" } }
    @client.reload
    assert_nil @client.alias
  end

  test "update with whitespace-only alias clears alias to nil" do
    @client.update!(alias: "Existing Alias")
    patch admin_client_path(@client), params: { client: { alias: "   " } }
    @client.reload
    assert_nil @client.alias
  end

  test "update with oversized alias re-renders show with 422" do
    patch admin_client_path(@client), params: { client: { alias: "a" * 101 } }
    assert_response :unprocessable_entity
  end

  test "update does not change client_identifier" do
    original_identifier = @client.client_identifier
    patch admin_client_path(@client), params: { client: { alias: "New Alias" } }
    @client.reload
    assert_equal original_identifier, @client.client_identifier
  end

  test "update does not change last_fact_id" do
    @client.update!(last_fact_id: 7)
    patch admin_client_path(@client), params: { client: { alias: "New Alias" } }
    @client.reload
    assert_equal 7, @client.last_fact_id
  end

  # ---------------------------------------------------------------------------
  # T018 – Alias visibility on index and show (US3)
  # ---------------------------------------------------------------------------

  test "index shows alias when client has alias" do
    @client.update!(alias: "Visible Alias")
    get admin_clients_path
    assert_response :success
    assert_match "Visible Alias", response.body
  end

  test "index shows fallback when client has no alias" do
    @client.update!(alias: nil)
    get admin_clients_path
    assert_response :success
    assert_match "No alias defined", response.body
  end

  test "index always shows client identifier regardless of alias presence" do
    @client.update!(alias: "Has Alias")
    get admin_clients_path
    assert_response :success
    assert_match @client.client_identifier, response.body
  end

  test "show displays alias when present" do
    @client.update!(alias: "Detail Alias")
    get admin_client_path(@client)
    assert_response :success
    assert_match "Detail Alias", response.body
  end

  test "show displays fallback when alias is absent" do
    @client.update!(alias: nil)
    get admin_client_path(@client)
    assert_response :success
    assert_match "No alias defined", response.body
  end

  test "show always displays client identifier" do
    get admin_client_path(@client)
    assert_response :success
    assert_match @client.client_identifier, response.body
  end
end
