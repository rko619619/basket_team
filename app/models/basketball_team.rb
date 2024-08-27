# app/models/basketball_team.rb

class BasketballTeam < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :coaches, dependent: :destroy

  validates :name, presence: true
end
