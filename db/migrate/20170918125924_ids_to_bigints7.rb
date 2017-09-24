class IdsToBigints7 < ActiveRecord::Migration[5.1]
  def up
    change_column :follow_requests, :account_id, :bigint
    change_column :follow_requests, :id, :bigint
    change_column :follow_requests, :target_account_id, :bigint
  end

  def down
    change_column :follow_requests, :account_id, :integer
    change_column :follow_requests, :id, :integer
    change_column :follow_requests, :target_account_id, :integer
  end
end
