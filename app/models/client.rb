class Client < ApplicationRecord
  before_validation :generate_client_identifier, on: :create

  validates :client_identifier, presence: true, uniqueness: true

  def reset_progression!
    update!(last_fact_id: nil)
  end

  private

  def generate_client_identifier
    self.client_identifier ||= SecureRandom.hex(16)
  end
end
