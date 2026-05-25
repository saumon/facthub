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
    Fact.delete_all
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
    Fact.delete_all
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

  # =========================================================
  # T007 + T010 (US1): Previous and next navigation
  # =========================================================

  test "index shows only 10 facts on first page" do
    # 23 fixtures loaded — page 1 shows exactly 10 rows
    visit admin_facts_path
    assert_selector "tbody tr", count: 10
  end

  test "next page navigation shows different facts" do
    visit admin_facts_path(page: 1)
    # Fact on page 1
    assert_text "An interesting fact about the world."
    # Navigate to page 2
    click_link "Next"
    assert_no_text "An interesting fact about the world."
    # A fact from page 2 should be visible
    assert_text "The Great Wall of China is not visible from space with the naked eye."
  end

  test "previous page navigation returns to prior page" do
    visit admin_facts_path(page: 2)
    click_link "Previous"
    assert_text "An interesting fact about the world."
  end

  test "edit link preserves page context" do
    visit admin_facts_path(page: 2)
    # Click edit on first fact visible on page 2
    first("tbody tr").click_link("Edit")
    # Back link should target page 2
    assert_selector "a[href*='page=2']", text: "Back to Facts"
  end

  test "edit fact returns to same page on success" do
    visit admin_facts_path(page: 2)
    first("tbody tr").click_link("Edit")
    fill_in "Body", with: "Updated body for page context test."
    click_button "Update Fact"
    assert_text "Fact was successfully updated"
    assert_current_path admin_facts_path(page: 2)
  end

  # =========================================================
  # T012 + T015 (US2): First-page and last-page controls
  # =========================================================

  test "first and last navigation links are present on middle page" do
    visit admin_facts_path(page: 2)
    assert_selector "a", text: "First"
    assert_selector "a", text: "Last"
  end

  test "last page navigation shows final facts" do
    visit admin_facts_path(page: 1)
    click_link "Last"
    # Page 3 has 3 facts (21, 22, 23)
    assert_text "Cleopatra lived closer in time to the moon landing than to the Great Pyramid."
    assert_selector "tbody tr:not([aria-hidden])", count: 3
  end

  test "first page navigation returns to beginning" do
    visit admin_facts_path(page: 3)
    click_link "First"
    assert_text "An interesting fact about the world."
    assert_selector "tbody tr", count: 10
  end

  test "page position indicator shows current and total pages" do
    visit admin_facts_path(page: 2)
    assert_text "Page 2 of 3"
  end

  # =========================================================
  # T017 + T021 (US3): Boundary states and delete fallback
  # =========================================================

  test "single-page list shows no pagination controls" do
    # Keep only 5 facts — fits on one page
    Fact.order(created_at: :asc, id: :asc).last(18).each(&:destroy)
    visit admin_facts_path
    assert_no_selector "a", text: "Next"
    assert_no_selector "a", text: "Previous"
    assert_no_selector "a", text: "First"
    assert_no_selector "a", text: "Last"
  end

  test "first page shows disabled previous and first controls" do
    visit admin_facts_path(page: 1)
    # Disabled spans (not links) for First and Previous on first page
    assert_no_selector "a", text: "First"
    assert_no_selector "a", text: "Previous"
  end

  test "last page shows disabled next and last controls" do
    visit admin_facts_path(page: 3)
    assert_no_selector "a", text: "Next"
    assert_no_selector "a", text: "Last"
  end

  test "invalid page redirects to valid page" do
    visit admin_facts_path(page: 999)
    # Should land on page 3 (last page with 23 facts)
    assert_text "Page 3 of 3"
  end

  test "delete from last page falls back to nearest valid page" do
    # Navigate to page 3 which has 3 facts
    visit admin_facts_path(page: 3)
    assert_text "Page 3 of 3"
    assert_selector "tbody tr:not([aria-hidden])", count: 3

    # Delete all 3 facts on page 3 to collapse the page.
    # Re-find the element inside accept_confirm each iteration to avoid
    # StaleElementReferenceError after Turbo navigates on each delete.
    3.times do
      accept_confirm do
        first("tbody tr a", text: "Delete").click
      end
      assert_text "Fact was successfully deleted"
    end

    # After deleting all 3 page-3 facts, 20 remain → page 2 is now the last
    assert_text "Page 2 of 2"
  end
end
