class AddTrustLevelToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :trust_level, :integer
  end
end
