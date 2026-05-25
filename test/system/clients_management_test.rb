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
    assert_text(/last fact served/i)
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

  # ---------------------------------------------------------------------------
  # T008/T011 – Create with alias (US1)
  # ---------------------------------------------------------------------------

  test "admin can create a client with an alias and see it on the detail page" do
    visit new_admin_client_path
    fill_in "Alias (optional)", with: "Operations West"
    click_button "Create Client"
    assert_text "Client was successfully created."
    assert_text "Operations West"
    assert_selector "code", text: /[a-f0-9]{32}/
  end

  test "admin can create a client without an alias and sees fallback on detail page" do
    visit new_admin_client_path
    click_button "Create Client"
    assert_text "Client was successfully created."
    assert_text "No alias defined"
    assert_selector "code", text: /[a-f0-9]{32}/
  end

  test "whitespace-only alias on create is treated as no alias" do
    visit new_admin_client_path
    fill_in "Alias (optional)", with: "   "
    click_button "Create Client"
    assert_text "Client was successfully created."
    assert_text "No alias defined"
  end

  test "alias trimmed on create and shown trimmed on detail page" do
    visit new_admin_client_path
    fill_in "Alias (optional)", with: "  Team Alpha  "
    click_button "Create Client"
    assert_text "Client was successfully created."
    assert_text "Team Alpha"
    assert_no_text "  Team Alpha  "
  end

  test "oversized alias on create re-renders form with validation error" do
    visit new_admin_client_path
    fill_in "Alias (optional)", with: "a" * 101
    click_button "Create Client"
    assert_text "is too long"
    assert_current_path new_admin_client_path
    assert_selector "input[name='client[alias]']"
  end

  test "validation error on create preserves submitted alias in the form field" do
    visit new_admin_client_path
    oversized = "a" * 101
    fill_in "Alias (optional)", with: oversized
    click_button "Create Client"
    assert_selector "input[name='client[alias]'][value='#{"a" * 101}']"
  end

  test "new client with alias appears in the clients list with alias shown" do
    visit new_admin_client_path
    fill_in "Alias (optional)", with: "Listed Alias"
    click_button "Create Client"
    assert_text "Client was successfully created."
    visit admin_clients_path
    assert_text "Listed Alias"
  end

  # ---------------------------------------------------------------------------
  # T014/T017 – Alias update (US2)
  # ---------------------------------------------------------------------------

  test "admin can add an alias from the detail page" do
    client = Client.create!
    visit admin_client_path(client)
    assert_text "No alias defined"
    fill_in "Enter alias (optional)", with: "New Alias"
    click_button "Save"
    assert_text "Alias was successfully updated."
    assert_text "New Alias"
  end

  test "admin can change an existing alias from the detail page" do
    client = Client.create!(alias: "Old Alias")
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: "Changed Alias"
    click_button "Save"
    assert_text "Alias was successfully updated."
    assert_text "Changed Alias"
    assert_no_text "Old Alias"
  end

  test "admin can clear an alias from the detail page" do
    client = Client.create!(alias: "To Be Cleared")
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: ""
    click_button "Save"
    assert_text "Alias was successfully updated."
    assert_text "No alias defined"
  end

  test "updated alias is immediately visible in the clients list" do
    client = Client.create!
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: "Index Visible"
    click_button "Save"
    assert_text "Alias was successfully updated."
    visit admin_clients_path
    assert_text "Index Visible"
  end

  test "cleared alias shows fallback in the clients list" do
    client = Client.create!(alias: "Will Be Cleared")
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: ""
    click_button "Save"
    visit admin_clients_path
    assert_text "No alias defined"
  end

  test "oversized alias on update re-renders show with validation error" do
    client = Client.create!
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: "a" * 101
    click_button "Save"
    assert_text "is too long"
    assert_current_path admin_client_path(client)
  end

  test "alias update does not lose destructive action buttons" do
    client = Client.create!(alias: "Keep Actions")
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: "Updated"
    click_button "Save"
    assert_text "Alias was successfully updated."
    assert_button "Reset Progression"
    assert_button "Delete Client"
  end

  test "client identifier remains visible after alias update" do
    client = Client.create!
    identifier = client.client_identifier
    visit admin_client_path(client)
    fill_in "Enter alias (optional)", with: "Has Identifier"
    click_button "Save"
    assert_text identifier
  end

  # ---------------------------------------------------------------------------
  # T019/T022 – Alias and identifier visibility in list/detail (US3)
  # ---------------------------------------------------------------------------

  test "clients list shows alias for clients that have one" do
    client = Client.create!(alias: "List Alias")
    visit admin_clients_path
    assert_text "List Alias"
    assert_text client.client_identifier
  end

  test "clients list shows fallback for clients without alias" do
    client = Client.create!
    visit admin_clients_path
    assert_text "No alias defined"
    assert_text client.client_identifier
  end

  test "client detail shows alias when present alongside identifier" do
    client = Client.create!(alias: "Detail Present")
    visit admin_client_path(client)
    assert_text "Detail Present"
    assert_text client.client_identifier
  end

  test "client detail shows fallback when alias absent alongside identifier" do
    client = Client.create!
    visit admin_client_path(client)
    assert_text "No alias defined"
    assert_text client.client_identifier
  end

  test "existing reset and delete confirmations still work after alias feature" do
    client = Client.create!(alias: "Regression")
    visit admin_client_path(client)
    assert_button "Reset Progression"
    assert_button "Delete Client"
  end
end
