class IdsToBigints17 < ActiveRecord::Migration[5.1]
  def up
    change_column :reports, :account_id, :bigint
    change_column :reports, :action_taken_by_account_id, :bigint
    change_column :reports, :id, :bigint
    change_column :reports, :target_account_id, :bigint
  end

  def down
    change_column :reports, :account_id, :integer
    change_column :reports, :action_taken_by_account_id, :integer
    change_column :reports, :id, :integer
    change_column :reports, :target_account_id, :integer
  end
end
