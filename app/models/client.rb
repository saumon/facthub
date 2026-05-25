class Client < ApplicationRecord
  before_validation :generate_client_identifier, on: :create
  before_validation :normalize_alias

  validates :client_identifier, presence: true, uniqueness: true
  validates :alias, length: { maximum: 100, allow_blank: true }

  def reset_progression!
    update!(last_fact_id: nil)
  end

  private

  def generate_client_identifier
    self.client_identifier ||= SecureRandom.hex(16)
  end

  def normalize_alias
    self.alias = self.alias&.strip
    self.alias = nil if self.alias&.empty?
  end
end
