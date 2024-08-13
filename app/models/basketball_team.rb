class BasketballTeam < ApplicationRecord
  has_many :players, dependent: :destroy
  validates :name, :description, presence: true
end
