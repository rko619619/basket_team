class Coach < ApplicationRecord
  belongs_to :basketball_team

  # Validations
  validates :first_name, :last_name, :date_of_birth, :license_number, :position, presence: true
  validates :license_number, uniqueness: true
end
