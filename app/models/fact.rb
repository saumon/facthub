class Fact < ApplicationRecord
  validates :body, presence: true, uniqueness: { case_sensitive: true }, length: { maximum: 500 }
end
