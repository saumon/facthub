require "application_system_test_case"

class AdminAuthTest < ApplicationSystemTestCase
  setup do
    Capybara.reset_session!
    @admin = Admin.create!(email: "sysadmin@example.com", password: "password123")
  end

  teardown do
    @admin.destroy
  end

  test "unauthenticated GET /admin/facts redirects to sign-in" do
    visit admin_facts_path
    assert_current_path new_admin_session_path
  end

  test "valid credentials on sign-in form opens admin area" do
    visit new_admin_session_path
    fill_in "Email", with: "sysadmin@example.com"
    fill_in "Password", with: "password123"
    click_button "Sign in"
    assert_current_path admin_facts_path
  end

  test "invalid credentials show Devise flash error" do
    visit new_admin_session_path
    fill_in "Email", with: "sysadmin@example.com"
    fill_in "Password", with: "wrongpassword"
    click_button "Sign in"
    assert_text "Invalid email or password"
  end
end
