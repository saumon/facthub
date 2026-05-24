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

  # ---------------------------------------------------------------------------
  # GET /api/facts/next — US1 success and empty-catalog
  # ---------------------------------------------------------------------------

  test "GET /api/facts/next returns 200 with JSON for known client when facts exist" do
    Client.delete_all
    Fact.delete_all
    client = Client.create!
    fact = Fact.create!(body: "First sequential fact")

    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal fact.id, json["id"]
    assert_equal fact.body, json["body"]
    assert_equal "application/json", response.media_type
  end

  test "GET /api/facts/next returns facts in ascending id order" do
    Client.delete_all
    Fact.delete_all
    client = Client.create!
    f1 = Fact.create!(body: "Sequential fact 1")
    f2 = Fact.create!(body: "Sequential fact 2")
    f3 = Fact.create!(body: "Sequential fact 3")

    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_equal f1.id, JSON.parse(response.body)["id"]
    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_equal f2.id, JSON.parse(response.body)["id"]
    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_equal f3.id, JSON.parse(response.body)["id"]
    # wrap-around
    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_equal f1.id, JSON.parse(response.body)["id"]
  end

  test "GET /api/facts/next returns 404 no_facts_available when catalog is empty" do
    Client.delete_all
    Fact.delete_all
    client = Client.create!

    get "/api/facts/next?client_id=#{client.client_identifier}"
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "no_facts_available", json["error"]
  end

  test "GET /api/facts/next responds within 2 seconds" do
    Client.delete_all
    client = Client.create!
    start = Time.now
    get "/api/facts/next?client_id=#{client.client_identifier}"
    elapsed = Time.now - start
    assert elapsed < 2, "GET /api/facts/next took #{elapsed}s (expected < 2s, SC-001)"
  end

  # ---------------------------------------------------------------------------
  # GET /api/facts/next — US2 rejection of unknown/missing clients
  # ---------------------------------------------------------------------------

  test "GET /api/facts/next returns 400 when client_id is missing" do
    get "/api/facts/next"
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_equal "missing_client_id", json["error"]
    assert_equal "client_id is required.", json["message"]
  end

  test "GET /api/facts/next returns 400 when client_id is blank" do
    get "/api/facts/next?client_id="
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_equal "missing_client_id", json["error"]
  end

  test "GET /api/facts/next returns 404 when client_id is unknown" do
    get "/api/facts/next?client_id=does_not_exist_xyz"
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "unknown_client", json["error"]
    assert_equal "No eligible client matches the provided client_id.", json["message"]
  end

  test "GET /api/facts/next returns 404 for deleted client identifier" do
    Client.delete_all
    client = Client.create!
    identifier = client.client_identifier
    client.destroy

    get "/api/facts/next?client_id=#{identifier}"
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "unknown_client", json["error"]
  end

  test "GET /api/facts/next does not return a fact body when client is unknown" do
    get "/api/facts/next?client_id=ghost_identifier"
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_nil json["body"]
    assert_nil json["id"]
  end
end
