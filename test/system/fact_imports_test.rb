require "application_system_test_case"

class FactImportsTest < ApplicationSystemTestCase
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    Capybara.reset_session!
    # Perform jobs inline during system tests
    ActiveJob::Base.queue_adapter = :inline

    visit new_admin_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path admin_facts_path
  end

  teardown do
    ActiveJob::Base.queue_adapter = :test
  end

  # ── Setup page is accessible via nav ─────────────────────────────────────

  test "setup link is visible in admin navigation" do
    visit admin_facts_path
    assert_link "Setup"
  end

  test "setup page loads with upload form" do
    visit admin_setup_path
    assert_text "Import Facts from Markdown"
    assert_selector "input[type='file']"
    assert_button "Start Import"
  end

  # ── US1: valid import flow with progress bar ──────────────────────────────

  test "importing a valid file shows progress region and success summary" do
    Fact.delete_all

    visit admin_setup_path

    attach_file find("input[type='file']")["name"],
                Rails.root.join("test/fixtures/files/facts_import_valid.md").to_s,
                make_visible: true

    click_button "Start Import"

    # Progress region must appear
    assert_selector "[data-import-target='progressRegion']:not(.hidden)", wait: 5

    # Wait for terminal summary
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    within "[data-import-target='summaryRegion']" do
      assert_text "facts added"
    end
  end

  test "facts imported from valid file appear in facts index" do
    Fact.delete_all

    visit admin_setup_path

    attach_file find("input[type='file']")["name"],
                Rails.root.join("test/fixtures/files/facts_import_valid.md").to_s,
                make_visible: true

    click_button "Start Import"
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    visit admin_facts_path
    assert_text "The Eiffel Tower can grow"
  end

  # ── US2: duplicate-aware multi-file import ────────────────────────────────

  test "re-importing the same file counts duplicates as ignored" do
    Fact.delete_all

    # First import
    visit admin_setup_path
    attach_file find("input[type='file']")["name"],
                Rails.root.join("test/fixtures/files/facts_import_valid.md").to_s,
                make_visible: true
    click_button "Start Import"
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    # Second import (all facts are now duplicates)
    visit admin_setup_path
    attach_file find("input[type='file']")["name"],
                Rails.root.join("test/fixtures/files/facts_import_valid.md").to_s,
                make_visible: true
    click_button "Start Import"
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    within "[data-import-target='summaryRegion']" do
      assert_text "duplicates ignored"
    end
  end

  # ── US3: invalid file feedback ────────────────────────────────────────────

  test "importing an invalid file shows rejected status and reason" do
    visit admin_setup_path

    attach_file find("input[type='file']")["name"],
                Rails.root.join("test/fixtures/files/facts_import_invalid.md").to_s,
                make_visible: true

    click_button "Start Import"
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    within "[data-import-target='summaryRegion']" do
      assert_text "rejected"
    end
  end

  test "valid file in same batch still succeeds when another file is invalid" do
    Fact.delete_all

    visit admin_setup_path

    # Attach both files
    input = find("input[type='file']")
    attach_file input["name"], [
      Rails.root.join("test/fixtures/files/facts_import_valid.md").to_s,
      Rails.root.join("test/fixtures/files/facts_import_invalid.md").to_s
    ], make_visible: true

    click_button "Start Import"
    assert_selector "[data-import-target='summaryRegion']:not(.hidden)", wait: 10

    within "[data-import-target='summaryRegion']" do
      assert_text "facts added"
      assert_text "rejected"
    end
  end
end
