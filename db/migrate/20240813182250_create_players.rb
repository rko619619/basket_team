class CreatePlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :players do |t|
      t.string :last_name
      t.string :first_name
      t.date :birthdate
      t.string :license_number
      t.string :basketball_citizenship
      t.string :jersey_number
      t.references :basketball_team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
