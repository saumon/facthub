require "test_helper"

class Admin::FactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
    sign_in @admin
    @fact = facts(:one)
  end

  test "index returns 200 when signed in" do
    get admin_facts_path
    assert_response :success
  end

  test "index redirects when not signed in" do
    sign_out @admin
    get admin_facts_path
    assert_redirected_to new_admin_session_path
  end

  test "create succeeds and redirects" do
    assert_difference "Fact.count", 1 do
      post admin_facts_path, params: { fact: { body: "A brand new unique fact." } }
    end
    assert_redirected_to admin_facts_path
    follow_redirect!
    assert_response :success
  end

  test "create with duplicate body returns 422" do
    post admin_facts_path, params: { fact: { body: @fact.body } }
    assert_response :unprocessable_entity
  end

  test "create with blank body returns 422" do
    post admin_facts_path, params: { fact: { body: "" } }
    assert_response :unprocessable_entity
  end

  test "update succeeds and redirects" do
    patch admin_fact_path(@fact), params: { fact: { body: "Updated fact body text." } }
    assert_redirected_to admin_facts_path
  end

  test "update with duplicate body returns 422" do
    other = Fact.create!(body: "Another existing fact body")
    patch admin_fact_path(@fact), params: { fact: { body: other.body } }
    assert_response :unprocessable_entity
  end

  test "destroy succeeds and redirects" do
    assert_difference "Fact.count", -1 do
      delete admin_fact_path(@fact)
    end
    assert_redirected_to admin_facts_path
  end
end
