class OptimizeIndexSubscriptions < ActiveRecord::Migration[5.0]
  def up
    add_index :subscriptions, [:account_id, :callback_url], unique: true
    remove_index :subscriptions, [:callback_url, :account_id]
  end

  def down
    add_index :subscriptions, [:callback_url, :account_id], unique: true
    remove_index :subscriptions, [:account_id, :callback_url]
  end
end
