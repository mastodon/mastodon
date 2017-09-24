class IdsToBigints23 < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :account_id, :bigint
    change_column :users, :id, :bigint
  end

  def down
    change_column :users, :account_id, :integer
    change_column :users, :id, :integer
  end
end
