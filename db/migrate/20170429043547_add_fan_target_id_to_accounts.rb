class AddFanTargetIdToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :fan_target_id, :integer
    add_index :accounts, :fan_target_id
  end
end
