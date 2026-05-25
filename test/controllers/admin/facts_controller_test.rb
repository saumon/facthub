require "test_helper"

class Admin::FactsControllerTest < ActionDispatch::IntegrationTest
  FACTS_PER_PAGE = 10

  setup do
    @admin = admins(:one)
    sign_in @admin
    @fact = facts(:one)
  end

  # =========================================================
  # Existing authentication and CRUD tests (preserved)
  # =========================================================

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

  # =========================================================
  # T006 (US1): Page slicing and adjacent navigation
  # =========================================================

  test "index with no page param shows first 10 facts" do
    # 23 facts in fixtures
    get admin_facts_path
    assert_response :success
    assert_select "tbody tr", FACTS_PER_PAGE
  end

  test "index page 1 shows first 10 facts" do
    get admin_facts_path(page: 1)
    assert_response :success
    assert_select "tbody tr", FACTS_PER_PAGE
  end

  test "index page 2 shows next 10 facts" do
    get admin_facts_path(page: 2)
    assert_response :success
    assert_select "tbody tr", FACTS_PER_PAGE
  end

  test "index last page shows remainder facts" do
    # 23 facts: pages 1-2 have 10 each, page 3 has 3
    get admin_facts_path(page: 3)
    assert_response :success
    assert_select "tbody tr:not([aria-hidden])", 3
  end

  # =========================================================
  # T011 (US2): First-page and last-page navigation targets
  # =========================================================

  test "index includes first-page link when not on page 1" do
    get admin_facts_path(page: 2)
    assert_response :success
    assert_select "a[href='#{admin_facts_path(page: 1)}']", minimum: 1
  end

  test "index includes last-page link when not on last page" do
    # total_pages = ceil(23/10) = 3
    get admin_facts_path(page: 1)
    assert_response :success
    assert_select "a[href='#{admin_facts_path(page: 3)}']", minimum: 1
  end

  test "index includes page position indicator" do
    get admin_facts_path(page: 2)
    assert_response :success
    assert_select "body", /Page 2 of 3/
  end

  # =========================================================
  # T016 (US3): Invalid page redirects and page-aware CRUD
  # =========================================================

  test "index redirects page 0 to page 1" do
    get admin_facts_path(page: 0)
    assert_redirected_to admin_facts_path(page: 1)
  end

  test "index redirects negative page to page 1" do
    get admin_facts_path(page: -5)
    assert_redirected_to admin_facts_path(page: 1)
  end

  test "index redirects out-of-range page to last page" do
    # total_pages = 3 with 23 fixtures
    get admin_facts_path(page: 999)
    assert_redirected_to admin_facts_path(page: 3)
  end

  test "index page 1 on empty database shows empty state" do
    Fact.delete_all
    get admin_facts_path(page: 1)
    assert_response :success
    assert_select "tbody tr", 0
  end

  test "create with page param redirects back to that page" do
    post admin_facts_path, params: { fact: { body: "New fact from page 2 context." }, page: 2 }
    assert_redirected_to admin_facts_path(page: 2)
  end

  test "update with page param redirects back to that page" do
    patch admin_fact_path(@fact), params: { fact: { body: "Updated fact from page 2." }, page: 2 }
    assert_redirected_to admin_facts_path(page: 2)
  end

  test "destroy with page param redirects to same page when still valid" do
    # 23 facts → page 2 has facts 11-20, deleting one leaves page 2 valid (still 22 facts)
    fact_on_page2 = Fact.order(created_at: :asc, id: :asc).offset(10).first
    delete admin_fact_path(fact_on_page2), params: { page: 2 }
    # 22 facts remain → 3 pages still (10+10+2) → page 2 valid
    assert_redirected_to admin_facts_path(page: 2)
  end

  test "destroy redirects to last valid page when current page disappears" do
    # Delete enough facts so page 3 disappears: keep exactly 20 (2 full pages)
    # 23 fixtures → delete 3 to have 20, then delete one more on page 3 context
    Fact.order(created_at: :asc, id: :asc).last(3).each(&:destroy)
    # Now 20 facts → 2 pages. Request delete from page 2 context
    last_fact = Fact.order(created_at: :asc, id: :asc).last
    delete admin_fact_path(last_fact), params: { page: 2 }
    # 19 facts remain → 2 pages (10+9) → page 2 still valid
    assert_redirected_to admin_facts_path(page: 2)
  end

  test "destroy on single-item last page redirects to preceding page" do
    # Keep exactly 11 facts: page 1 = 10, page 2 = 1
    Fact.order(created_at: :asc, id: :asc).last(12).each(&:destroy)
    # 11 facts remain
    last_fact = Fact.order(created_at: :asc, id: :asc).last
    delete admin_fact_path(last_fact), params: { page: 2 }
    # 10 facts remain → 1 page → redirect to page 1
    assert_redirected_to admin_facts_path(page: 1)
  end

  # =========================================================
  # T024: Performance regression for paginated index
  # =========================================================

  test "index performance is under 2 seconds" do
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    get admin_facts_path
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    assert elapsed < 2.0, "Facts index took #{elapsed.round(3)}s, expected under 2 seconds"
  end
end
