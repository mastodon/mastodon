class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :account_id
      t.integer :activity_id
      t.string :activity_type

      t.timestamps
    end

    add_index :notifications, :account_id
  end
end
