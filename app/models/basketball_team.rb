class BasketballTeam < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :coaches, dependent: :destroy
  validates :name, :description, presence: true
end
