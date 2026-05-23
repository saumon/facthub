require "application_system_test_case"

class FactsManagementTest < ApplicationSystemTestCase
  setup do
    Capybara.reset_session!
    visit new_admin_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path admin_facts_path
  end

  teardown do
    # Fixture admin is rolled back by the test transaction — no cleanup needed
  end

  test "index shows list of facts" do
    visit admin_facts_path
    assert_text "An interesting fact about the world."
  end

  test "index shows empty state when no facts" do
    Fact.delete_all
    visit admin_facts_path
    assert_text "No fun facts yet"
  end

  test "add fact shows success flash" do
    visit new_admin_fact_path
    fill_in "Body", with: "A brand new system test fact."
    click_button "Create Fact"
    assert_text "Fact was successfully created"
  end

  test "edit fact shows success flash" do
    visit new_admin_fact_path
    fill_in "Body", with: "Original system test fact body."
    click_button "Create Fact"
    assert_text "Fact was successfully created"
    within(find("tr", text: "Original system test fact body.")) do
      click_link "Edit"
    end
    fill_in "Body", with: "Updated system test fact body."
    click_button "Update Fact"
    assert_text "Fact was successfully updated"
  end

  test "delete fact shows success flash" do
    visit new_admin_fact_path
    fill_in "Body", with: "Fact to be deleted in system test."
    click_button "Create Fact"
    assert_text "Fact was successfully created"
    within(find("tr", text: "Fact to be deleted in system test.")) do
      accept_confirm do
        click_link "Delete"
      end
    end
    assert_text "Fact was successfully deleted"
  end

  test "duplicate submission shows validation error" do
    visit new_admin_fact_path
    fill_in "Body", with: "An interesting fact about the world."
    click_button "Create Fact"
    assert_text "Body has already been taken"
  end

  test "blank body shows validation error" do
    visit new_admin_fact_path
    fill_in "Body", with: ""
    click_button "Create Fact"
    assert_text "Body can't be blank"
  end
end
