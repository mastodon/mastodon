class IdsToBigints20 < ActiveRecord::Migration[5.1]
  def up
    change_column :stream_entries, :account_id, :bigint
    change_column :stream_entries, :id, :bigint
  end

  def down
    change_column :stream_entries, :account_id, :integer
    change_column :stream_entries, :id, :integer
  end
end
