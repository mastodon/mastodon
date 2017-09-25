class IdsToBigints3 < ActiveRecord::Migration[5.1]
  def up
    change_column :blocks, :account_id, :bigint
    change_column :blocks, :id, :bigint
    change_column :blocks, :target_account_id, :bigint
  end

  def down
    change_column :blocks, :account_id, :integer
    change_column :blocks, :id, :integer
    change_column :blocks, :target_account_id, :integer
  end
end
