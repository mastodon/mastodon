class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :account_id
      t.integer :activity_id
      t.string :activity_type

      t.timestamps
    end

    add_index :notifications, :account_id
    add_index :notifications, %i(account_id activity_id activity_type), unique: true, name: 'account_activity'
  end
end
