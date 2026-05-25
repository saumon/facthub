class FactImportFile < ApplicationRecord
  STATUSES = %w[pending processing completed rejected_invalid rejected_too_large failed].freeze
  TERMINAL_STATUSES = %w[completed rejected_invalid rejected_too_large failed].freeze

  belongs_to :fact_import_run

  validates :filename, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :total_lines, :processed_lines, :added_facts_count, :ignored_duplicates_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def terminal?
    TERMINAL_STATUSES.include?(status)
  end

  def rejected?
    status.start_with?("rejected_")
  end
end
