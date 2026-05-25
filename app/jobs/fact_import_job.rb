class FactImportJob < ApplicationJob
  queue_as :default

  def perform(import_run_id, file_data_array)
    import_run = FactImportRun.find(import_run_id)

    # Reconstruct upload-like objects from serialized data
    uploads = file_data_array.map do |data|
      BufferedUpload.new(data["filename"], data["content"])
    end

    FactImportOrchestrator.new(import_run).call(uploads)
  rescue StandardError => e
    FactImportRun.find_by(id: import_run_id)&.update!(
      status: "failed",
      error_message: e.message,
      completed_at: Time.current
    )
    raise
  end

  # Thin wrapper that provides the interface expected by FactImportOrchestrator:
  # #original_filename and #read (content already serialized as String).
  class BufferedUpload
    attr_reader :original_filename

    def initialize(filename, content)
      @original_filename = filename
      @content           = content
    end

    def read
      @content
    end
  end
end
