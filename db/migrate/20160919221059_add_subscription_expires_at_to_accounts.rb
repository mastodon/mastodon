class AddSubscriptionExpiresAtToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :subscription_expires_at, :datetime, null: true, default: nil
  end
end
