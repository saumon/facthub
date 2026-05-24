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
    post admin_clients_path
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
      post admin_clients_path
    end
    created = Client.order(:created_at).last
    assert_redirected_to admin_client_path(created)
    follow_redirect!
    assert_response :success
  end

  test "created client has a generated client_identifier" do
    post admin_clients_path
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
end
