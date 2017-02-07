class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :account_id, null: false
      t.string :registration_id, null: false, default: ''

      t.timestamps
    end

    add_index :devices, :registration_id
    add_index :devices, :account_id
  end
end
