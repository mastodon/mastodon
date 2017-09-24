class IdsToBigints21 < ActiveRecord::Migration[5.1]
  def up
    change_column :subscriptions, :account_id, :bigint
    change_column :subscriptions, :id, :bigint
  end

  def down
    change_column :subscriptions, :account_id, :integer
    change_column :subscriptions, :id, :integer
  end
end
