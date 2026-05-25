class Admin::SetupController < Admin::BaseController
  before_action :set_import_run, only: [ :import_status ]

  def show
    @last_run = current_admin.fact_import_runs.recent.first
  end

  def create_import
    # Filter to real file uploads only (browsers send empty strings for empty file inputs)
    uploaded_files = Array(params[:files]).select { |f| f.respond_to?(:original_filename) }

    if uploaded_files.empty?
      render json: { error: "Please select at least one file." },
             status: :unprocessable_entity
      return
    end

    import_run = current_admin.fact_import_runs.create!(
      status: "pending",
      total_files: uploaded_files.size
    )

    # Serialize file content for background job (force UTF-8 from binary upload read)
    file_data = uploaded_files.map do |upload|
      content = upload.read
      content = content.force_encoding("UTF-8") if content.encoding == Encoding::BINARY
      { "filename" => upload.original_filename, "content" => content }
    end

    FactImportJob.perform_later(import_run.id, file_data)

    render json: {
      import_run_id: import_run.id,
      status: import_run.status,
      total_files: import_run.total_files,
      status_url: admin_setup_import_path(import_run)
    }, status: :accepted
  end

  def import_status
    render json: import_run_json(@import_run)
  end

  private

  def set_import_run
    @import_run = current_admin.fact_import_runs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  end

  def import_run_json(run)
    {
      id: run.id,
      status: run.status,
      total_files: run.total_files,
      processed_files: run.processed_files,
      total_lines: run.total_lines,
      processed_lines: run.processed_lines,
      progress_percent: run.progress_percent,
      added_facts_count: run.added_facts_count,
      ignored_duplicates_count: run.ignored_duplicates_count,
      invalid_files_count: run.invalid_files_count,
      files: run.fact_import_files.map { |f| import_file_json(f) },
      error_message: run.error_message,
      completed_at: run.completed_at
    }
  end

  def import_file_json(file)
    {
      filename: file.filename,
      status: file.status,
      total_lines: file.total_lines,
      processed_lines: file.processed_lines,
      added_facts_count: file.added_facts_count,
      ignored_duplicates_count: file.ignored_duplicates_count,
      error_message: file.error_message
    }
  end
end
