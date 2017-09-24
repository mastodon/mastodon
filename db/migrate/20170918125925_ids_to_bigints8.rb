class IdsToBigints8 < ActiveRecord::Migration[5.1]
  def up
    change_column :follows, :account_id, :bigint
    change_column :follows, :id, :bigint
    change_column :follows, :target_account_id, :bigint
  end

  def down
    change_column :follows, :account_id, :integer
    change_column :follows, :id, :integer
    change_column :follows, :target_account_id, :integer
  end
end
