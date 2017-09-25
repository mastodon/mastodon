class IdsToBigints12 < ActiveRecord::Migration[5.1]
  def up
    change_column :mutes, :account_id, :bigint
    change_column :mutes, :id, :bigint
    change_column :mutes, :target_account_id, :bigint
  end

  def down
    change_column :mutes, :account_id, :integer
    change_column :mutes, :id, :integer
    change_column :mutes, :target_account_id, :integer
  end
end
