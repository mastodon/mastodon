class RemoveSubscriptionExpiresAtFromAccounts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :accounts, :subscription_expires_at, :datetime, null: true, default: nil, precision: nil
    end
  end
end
