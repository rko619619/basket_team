class CreateBasketballTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :basketball_teams do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
