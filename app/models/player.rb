# app/models/player.rb
class Player < ApplicationRecord
  belongs_to :basketball_team

  has_one_attached :photo
  has_one_attached :citizenship_photo

  validates :last_name, :first_name, :birthdate, :license_number, :jersey_number, presence: true
end
