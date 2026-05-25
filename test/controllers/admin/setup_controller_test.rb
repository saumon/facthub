require "test_helper"

class Admin::SetupControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
    sign_in @admin
  end

  # ── GET /admin/setup ──────────────────────────────────────────────────────

  test "show returns 200 when signed in" do
    get admin_setup_path
    assert_response :success
  end

  test "show redirects when not signed in" do
    sign_out @admin
    get admin_setup_path
    assert_redirected_to new_admin_session_path
  end

  # ── POST /admin/setup/imports ─────────────────────────────────────────────

  test "create_import accepts multipart upload and returns 202" do
    file = fixture_file_upload("facts_import_valid.md", "text/markdown")
    assert_difference "FactImportRun.count", 1 do
      post admin_setup_imports_path, params: { files: [ file ] }
    end
    assert_response :accepted
    body = response.parsed_body
    assert body["import_run_id"].present?
    assert_equal "pending", body["status"]
    assert_equal 1, body["total_files"]
    assert body["status_url"].present?
  end

  test "create_import returns 422 when no file is submitted" do
    post admin_setup_imports_path, params: {}
    assert_response :unprocessable_entity
  end

  test "create_import redirects when not signed in" do
    sign_out @admin
    file = fixture_file_upload("facts_import_valid.md", "text/markdown")
    post admin_setup_imports_path, params: { files: [ file ] }
    assert_redirected_to new_admin_session_path
  end

  # ── GET /admin/setup/imports/:id ─────────────────────────────────────────

  test "import_status returns progress JSON for owned run" do
    run = fact_import_runs(:one)
    get admin_setup_import_path(run)
    assert_response :success
    body = response.parsed_body
    assert_equal run.id, body["id"]
    assert_equal run.status, body["status"]
    assert body.key?("progress_percent")
    assert body.key?("files")
  end

  test "import_status returns 404 for run owned by another admin" do
    other_admin = Admin.create!(email: "other@example.com", password: "password123")
    other_run = other_admin.fact_import_runs.create!(status: "pending", total_files: 0)
    get admin_setup_import_path(other_run)
    assert_response :not_found
  end

  test "import_status redirects when not signed in" do
    sign_out @admin
    run = fact_import_runs(:one)
    get admin_setup_import_path(run)
    assert_redirected_to new_admin_session_path
  end

  # ── US2: duplicate-count summaries ───────────────────────────────────────

  test "import_status exposes ignored_duplicates_count in response" do
    run = fact_import_runs(:completed)
    # The completed fixture has 0 ignored duplicates; just check the key exists
    get admin_setup_import_path(run)
    body = response.parsed_body
    assert body.key?("ignored_duplicates_count")
    assert body.key?("added_facts_count")
  end

  # ── US3: per-file rejection payloads ─────────────────────────────────────

  test "import_status returns file-level error_message for rejected files" do
    run = @admin.fact_import_runs.create!(status: "completed_with_errors",
                                          total_files: 1, processed_files: 1,
                                          total_lines: 3, processed_lines: 3,
                                          added_facts_count: 0, ignored_duplicates_count: 0,
                                          invalid_files_count: 1,
                                          started_at: 1.minute.ago, completed_at: Time.current)
    run.fact_import_files.create!(filename: "bad.md", status: "rejected_invalid",
                                  total_lines: 3, processed_lines: 1,
                                  added_facts_count: 0, ignored_duplicates_count: 0,
                                  error_message: "Invalid line at 2: BAD LINE")

    get admin_setup_import_path(run)
    assert_response :success
    body = response.parsed_body
    file = body["files"].first
    assert_equal "rejected_invalid", file["status"]
    assert_equal "Invalid line at 2: BAD LINE", file["error_message"]
  end
end
