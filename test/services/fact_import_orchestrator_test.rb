require "test_helper"
require "ostruct"

class FactImportOrchestratorTest < ActiveSupport::TestCase
  # ── helpers ──────────────────────────────────────────────────────────────

  def admin
    @admin ||= admins(:one)
  end

  def build_run
    admin.fact_import_runs.create!(status: "pending", total_files: 0)
  end

  def upload(filename, content)
    OpenStruct.new(original_filename: filename, read: content)
  end

  # ── US1: valid markdown parsing and line-based progress ──────────────────

  test "imports facts from a valid markdown file" do
    run = build_run
    content = "# Title\n\n- Fact Alpha\n- Fact Beta\n"
    orchestrator = FactImportOrchestrator.new(run)
    orchestrator.call([ upload("test.md", content) ])

    run.reload
    assert_equal "completed", run.status
    assert_equal 2, run.added_facts_count
    assert_equal 0, run.ignored_duplicates_count
    assert Fact.exists?(body: "Fact Alpha")
    assert Fact.exists?(body: "Fact Beta")
  end

  test "skips blank and title lines without counting as errors" do
    run = build_run
    content = "# Header\n\n- Fact One\n\n- Fact Two\n"
    FactImportOrchestrator.new(run).call([ upload("test.md", content) ])

    run.reload
    assert_equal "completed", run.status
    assert_equal 2, run.added_facts_count
  end

  test "updates progress_percent based on processed lines" do
    run = build_run
    content = "- Fact A\n- Fact B\n- Fact C\n- Fact D\n"
    FactImportOrchestrator.new(run).call([ upload("test.md", content) ])

    run.reload
    assert_equal 100, run.progress_percent
  end

  test "sets started_at and completed_at" do
    run = build_run
    FactImportOrchestrator.new(run).call([ upload("test.md", "- Solo fact\n") ])

    run.reload
    assert_not_nil run.started_at
    assert_not_nil run.completed_at
  end

  # ── US2: deduplication ───────────────────────────────────────────────────

  test "deduplicates facts already in the database" do
    existing = facts(:one)  # "An interesting fact about the world."
    run = build_run
    content = "- #{existing.body}\n- Brand new unique fact xyz\n"
    FactImportOrchestrator.new(run).call([ upload("test.md", content) ])

    run.reload
    assert_equal 1, run.added_facts_count
    assert_equal 1, run.ignored_duplicates_count
  end

  test "deduplicates facts within the same file" do
    run = build_run
    content = "- Same fact text\n- Same fact text\n"
    FactImportOrchestrator.new(run).call([ upload("test.md", content) ])

    run.reload
    assert_equal 1, run.added_facts_count
    assert_equal 1, run.ignored_duplicates_count
  end

  test "deduplicates facts across multiple files" do
    run = build_run
    content_a = "- Shared fact X\n- Only in A\n"
    content_b = "- Shared fact X\n- Only in B\n"
    FactImportOrchestrator.new(run).call([
      upload("a.md", content_a),
      upload("b.md", content_b)
    ])

    run.reload
    assert_equal 3, run.added_facts_count  # Shared fact X + Only in A + Only in B
    assert_equal 1, run.ignored_duplicates_count
  end

  test "persists per-file added and ignored counts" do
    run = build_run
    existing = facts(:two)  # "Another unique and fascinating fact."
    content = "- #{existing.body}\n- New fact for file test\n"
    FactImportOrchestrator.new(run).call([ upload("test.md", content) ])

    file_record = run.fact_import_files.first
    assert_equal 1, file_record.added_facts_count
    assert_equal 1, file_record.ignored_duplicates_count
  end

  # ── US3: invalid / empty / over-limit files ──────────────────────────────

  test "rejects a file with an invalid non-bullet non-title line" do
    run = build_run
    content = "- Good line\nThis is invalid\n- Another good line\n"
    FactImportOrchestrator.new(run).call([ upload("bad.md", content) ])

    run.reload
    assert_equal "completed_with_errors", run.status
    assert_equal 1, run.invalid_files_count
    assert_equal 0, run.added_facts_count

    file_record = run.fact_import_files.first
    assert_equal "rejected_invalid", file_record.status
    assert_not_nil file_record.error_message
  end

  test "rejects a file that exceeds 10,000 lines" do
    run = build_run
    content = (1..10_001).map { |i| "- Fact #{i}" }.join("\n")
    FactImportOrchestrator.new(run).call([ upload("huge.md", content) ])

    run.reload
    assert_equal "completed_with_errors", run.status
    assert_equal 1, run.invalid_files_count

    file_record = run.fact_import_files.first
    assert_equal "rejected_too_large", file_record.status
  end

  test "imports valid files when batch also contains an invalid file" do
    run = build_run
    valid_content   = "- Valid fact for mixed batch test\n"
    invalid_content = "- Good\nBAD LINE\n"

    FactImportOrchestrator.new(run).call([
      upload("valid.md", valid_content),
      upload("invalid.md", invalid_content)
    ])

    run.reload
    assert_equal "completed_with_errors", run.status
    assert_equal 1, run.added_facts_count
    assert_equal 1, run.invalid_files_count
    assert Fact.exists?(body: "Valid fact for mixed batch test")
  end

  test "rejected files produce no inserted facts" do
    run = build_run
    content = "This entire file is just prose\n"
    FactImportOrchestrator.new(run).call([ upload("prose.md", content) ])

    run.reload
    assert_equal 0, run.added_facts_count
  end

  test "counts progress correctly when files are rejected early" do
    run = build_run
    large = (1..10_001).map { |i| "- Fact #{i}" }.join("\n")
    FactImportOrchestrator.new(run).call([ upload("huge.md", large) ])

    run.reload
    # processed_lines must equal total_lines after the run
    assert_equal run.total_lines, run.processed_lines
  end

  # ── T024: performance regression for 10,000-line import ──────────────────

  test "completes a 10,000-line valid import within 120 seconds" do
    run = build_run
    content = (1..10_000).map { |i| "- Performance test fact number #{i}" }.join("\n")
    start = Time.current

    FactImportOrchestrator.new(run).call([ upload("perf.md", content) ])

    elapsed = Time.current - start
    assert elapsed < 120, "Expected import to complete in under 120s, took #{elapsed.round(1)}s"

    run.reload
    assert_equal "completed", run.status
    assert_equal 10_000, run.added_facts_count
  end

  # ── T033: duplicate-heavy performance ────────────────────────────────────

  test "handles a duplicate-heavy 10,000-line import within 120 seconds" do
    # Pre-insert half the facts so we have existing duplicates
    Fact.insert_all((1..100).map { |i| { body: "Dup heavy fact #{i}", created_at: Time.current, updated_at: Time.current } })

    run = build_run
    # 200 lines: first 100 are existing duplicates, next 100 are new
    content = (
      (1..100).map { |i| "- Dup heavy fact #{i}" } +
      (101..200).map { |i| "- Dup heavy fact #{i}" }
    ).join("\n")

    start = Time.current
    FactImportOrchestrator.new(run).call([ upload("dup.md", content) ])
    elapsed = Time.current - start

    assert elapsed < 120, "Expected duplicate-heavy import to complete within 120s, took #{elapsed.round(1)}s"

    run.reload
    assert_equal 100, run.added_facts_count
    assert_equal 100, run.ignored_duplicates_count
  end
end
