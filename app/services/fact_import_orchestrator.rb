class FactImportOrchestrator
  MAX_LINES = 10_000

  # Value object used during in-memory parsing
  ImportedFactCandidate = Struct.new(
    :raw_line_number,
    :raw_text,
    :normalized_body,
    :duplicate_scope,   # :batch_duplicate | :existing_duplicate | :new_candidate
    :validity,          # :valid | :blank | :over_length | :malformed
    keyword_init: true
  )

  def initialize(import_run)
    @import_run = import_run
    @batch_seen = {}  # normalized_body → true, for intra-batch deduplication
  end

  # Process each uploaded file (responds to #original_filename and #read).
  # Updates @import_run and its fact_import_files in place.
  def call(uploaded_files)
    # Read all file contents up front to compute total_lines
    file_contents = uploaded_files.map { |u| [ u.original_filename, u.read ] }

    total_lines = file_contents.sum { |_, content| content.lines.size }

    @import_run.update!(
      status: "processing",
      started_at: Time.current,
      total_files: uploaded_files.size,
      total_lines: total_lines
    )

    file_contents.each do |(filename, content)|
      process_file(filename, content)
    end

    finish_run
  end

  private

  def process_file(filename, content)
    lines = content.lines
    total = lines.size

    import_file = @import_run.fact_import_files.create!(
      filename: filename,
      status: "processing",
      total_lines: total
    )

    # Validate: over-limit
    if total > MAX_LINES
      import_file.update!(
        status: "rejected_too_large",
        processed_lines: 0,
        error_message: "File exceeds #{MAX_LINES}-line limit (#{total} lines)"
      )
      @import_run.increment!(:invalid_files_count)
      @import_run.increment!(:processed_lines, total)
      return
    end

    candidates = parse_lines(lines, import_file)

    if import_file.reload.status == "rejected_invalid"
      # parse_lines already incremented processed_lines on the run for this file
      return
    end

    # Persist valid new candidates
    added   = 0
    ignored = 0

    candidates.each do |c|
      case c.duplicate_scope
      when :new_candidate
        fact = Fact.new(body: c.normalized_body)
        if fact.save
          added += 1
        else
          # Concurrent insert — treat as duplicate
          ignored += 1
        end
        @batch_seen[c.normalized_body] = true
      when :batch_duplicate, :existing_duplicate
        ignored += 1
      end
    end

    import_file.update!(
      status: "completed",
      processed_lines: total,
      added_facts_count: added,
      ignored_duplicates_count: ignored
    )

    @import_run.increment!(:processed_files)
    @import_run.increment!(:added_facts_count, added)
    @import_run.increment!(:ignored_duplicates_count, ignored)
    @import_run.increment!(:processed_lines, total)
  end

  def parse_lines(lines, import_file)
    candidates = []
    total      = lines.size

    lines.each_with_index do |line, idx|
      stripped = line.chomp
      next if stripped.strip.empty? || stripped.strip.start_with?("#")

      unless stripped.strip.start_with?("- ")
        import_file.update!(
          status: "rejected_invalid",
          processed_lines: idx,
          error_message: "Invalid line at #{idx + 1}: #{stripped.strip.truncate(80)}"
        )
        @import_run.increment!(:invalid_files_count)
        # Count all lines of this file as processed (progress accounting)
        @import_run.increment!(:processed_lines, total)
        return []
      end

      body     = stripped.strip.sub(/\A- /, "").strip
      validity = classify_body(body)
      dup_scope = classify_duplicate(body, validity)

      candidates << ImportedFactCandidate.new(
        raw_line_number: idx + 1,
        raw_text: stripped,
        normalized_body: body,
        duplicate_scope: dup_scope,
        validity: validity
      )
    end

    candidates
  end

  def classify_body(body)
    return :blank      if body.blank?
    return :over_length if body.length > 500

    :valid
  end

  def classify_duplicate(body, validity)
    return :new_candidate unless validity == :valid
    return :batch_duplicate   if @batch_seen.key?(body)
    return :existing_duplicate if Fact.exists?(body: body)

    :new_candidate
  end

  def finish_run
    @import_run.reload
    terminal_status =
      if @import_run.invalid_files_count.positive?
        "completed_with_errors"
      else
        "completed"
      end

    @import_run.update!(
      status: terminal_status,
      completed_at: Time.current
    )
  end
end
