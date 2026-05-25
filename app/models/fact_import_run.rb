class FactImportRun < ApplicationRecord
  STATUSES = %w[pending processing completed completed_with_errors failed].freeze
  TERMINAL_STATUSES = %w[completed completed_with_errors failed].freeze

  belongs_to :admin
  has_many :fact_import_files, dependent: :destroy

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :total_files, :processed_files, :total_lines, :processed_lines,
            :added_facts_count, :ignored_duplicates_count, :invalid_files_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def progress_percent
    return 0 if total_lines.zero?

    ((processed_lines.to_f / total_lines) * 100).round
  end

  def terminal?
    TERMINAL_STATUSES.include?(status)
  end

  # Expose summaries scoped to a single admin for setup and facts pages
  scope :for_admin, ->(admin) { where(admin: admin) }
  scope :recent, -> { order(created_at: :desc) }
end
