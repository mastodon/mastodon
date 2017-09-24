class IdsToBigints13 < ActiveRecord::Migration[5.1]
  def up
    change_column :notifications, :account_id, :bigint
    change_column :notifications, :from_account_id, :bigint
    change_column :notifications, :id, :bigint
  end

  def down
    change_column :notifications, :account_id, :integer
    change_column :notifications, :from_account_id, :integer
    change_column :notifications, :id, :integer
  end
end
