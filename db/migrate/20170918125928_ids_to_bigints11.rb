class IdsToBigints11 < ActiveRecord::Migration[5.1]
  def up
    change_column :mentions, :account_id, :bigint
    change_column :mentions, :id, :bigint
  end

  def down
    change_column :mentions, :account_id, :integer
    change_column :mentions, :id, :integer
  end
end
