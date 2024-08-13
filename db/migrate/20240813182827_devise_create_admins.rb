class DeviseCreateAdmins < ActiveRecord::Migration[7.2]
  def change
    create_table :admins do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    # Add index for email uniqueness
    add_index :admins, :email, unique: true
  end
end
