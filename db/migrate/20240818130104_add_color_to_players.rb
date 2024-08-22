class AddColorToPlayers < ActiveRecord::Migration[7.2]
  def change
    add_column :players, :color, :string
  end
end
