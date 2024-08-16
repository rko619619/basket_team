class CreateCoaches < ActiveRecord::Migration[7.2]
  def change
    create_table :coaches do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :license_number
      t.string :position

      t.timestamps
    end
  end
end
