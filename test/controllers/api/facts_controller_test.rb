require "test_helper"

class Api::FactsControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/facts/random returns 200 with JSON when facts exist" do
    facts(:one)
    get "/api/facts/random"
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("id")
    assert json.key?("body")
    assert_equal "application/json", response.media_type
  end

  test "GET /api/facts/random returns 404 with error JSON when no facts" do
    Fact.delete_all
    get "/api/facts/random"
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "no_facts_available", json["error"]
    assert_equal "No fun facts are currently available.", json["message"]
  end

  test "GET /api/facts/random requires no authorization header" do
    get "/api/facts/random"
    assert_response :success
  end

  test "GET /api/facts/random responds within 2 seconds" do
    start = Time.now
    get "/api/facts/random"
    elapsed = Time.now - start
    assert elapsed < 2, "Response took #{elapsed}s (expected < 2s)"
  end

  test "fact deleted via destroy no longer returned" do
    Fact.delete_all
    fact = Fact.create!(body: "Only fact in catalog")
    get "/api/facts/random"
    assert_response :success
    fact.destroy
    get "/api/facts/random"
    assert_response :not_found
  end
end
