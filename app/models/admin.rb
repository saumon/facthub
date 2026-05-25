class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :database_authenticatable, :timeoutable, :validatable

  has_many :fact_import_runs, dependent: :destroy
end
