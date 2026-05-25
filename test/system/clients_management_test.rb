require "application_system_test_case"

class ClientsManagementTest < ApplicationSystemTestCase
  setup do
    Client.delete_all
    Capybara.reset_session!
    visit new_admin_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path admin_facts_path
  end

  # ---------------------------------------------------------------------------
  # Auth guard
  # ---------------------------------------------------------------------------

  test "clients management is inaccessible without authentication" do
    # Clear session cookies to simulate a signed-out browser
    Capybara.reset_session!
    visit admin_clients_path
    assert_current_path new_admin_session_path
  end

  # ---------------------------------------------------------------------------
  # Empty state
  # ---------------------------------------------------------------------------

  test "index shows empty state when no clients" do
    visit admin_clients_path
    assert_text "No eligible clients yet"
  end

  # ---------------------------------------------------------------------------
  # Client creation and identifier visibility
  # ---------------------------------------------------------------------------

  test "admin can create a client and see the generated identifier on the show page" do
    visit new_admin_client_path
    click_button "Create Client"
    assert_text "Client was successfully created."
    # The show page must display a non-empty client identifier
    assert_selector "code", text: /[a-f0-9]{32}/
  end

  test "created client appears in the clients list" do
    visit new_admin_client_path
    click_button "Create Client"
    assert_text "Client was successfully created."

    visit admin_clients_path
    assert_selector "td code, td", text: /[a-f0-9]{32}/
  end

  # ---------------------------------------------------------------------------
  # Progression display
  # ---------------------------------------------------------------------------

  test "new client shows no progression message on the list page" do
    visit new_admin_client_path
    click_button "Create Client"
    assert_text "Client was successfully created."

    visit admin_clients_path
    assert_text "No progress yet"
  end

  test "client detail page shows no progression initially" do
    visit new_admin_client_path
    click_button "Create Client"
    assert_text "Client was successfully created."
    assert_text "No facts served yet"
  end

  test "client detail page shows last fact id when progression is set" do
    # Set up DB state before browser visit so the server can see it
    client = Client.create!(last_fact_id: 7)
    visit admin_client_path(client)
    assert_text /last fact served/i
    assert_text "7"
  end

  # ---------------------------------------------------------------------------
  # Reset progression
  # ---------------------------------------------------------------------------

  test "admin can reset progression from the detail page" do
    client = Client.create!(last_fact_id: 42)
    visit admin_client_path(client)
    accept_confirm { click_button "Reset Progression" }
    assert_text "Client progression was reset."
    client.reload
    assert_nil client.last_fact_id
  end

  # ---------------------------------------------------------------------------
  # Delete client
  # ---------------------------------------------------------------------------

  test "admin can delete a client from the detail page and is redirected to index" do
    client = Client.create!
    visit admin_client_path(client)
    accept_confirm { click_button "Delete Client" }
    assert_current_path admin_clients_path
    assert_text "Client was successfully deleted."
  end

  test "deleted client identifier no longer appears in the clients list" do
    client = Client.create!
    identifier = client.client_identifier
    visit admin_client_path(client)
    accept_confirm { click_button "Delete Client" }
    assert_no_text identifier
  end

  # ---------------------------------------------------------------------------
  # Navigation
  # ---------------------------------------------------------------------------

  test "admin nav includes a Clients link" do
    visit admin_facts_path
    assert_link "Clients"
    click_link "Clients"
    assert_current_path admin_clients_path
  end
end
