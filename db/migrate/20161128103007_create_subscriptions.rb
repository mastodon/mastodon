class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.string :callback_url, null: false, default: ''
      t.string :secret
      t.datetime :expires_at, null: true, default: nil
      t.boolean :confirmed, null: false, default: false
      t.integer :account_id, null: false

      t.timestamps
    end

    add_index :subscriptions, [:callback_url, :account_id], unique: true
  end
end
