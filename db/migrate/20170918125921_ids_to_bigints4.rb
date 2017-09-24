class IdsToBigints4 < ActiveRecord::Migration[5.1]
  def up
    change_column :conversation_mutes, :account_id, :bigint
    change_column :conversation_mutes, :id, :bigint
  end

  def down
    change_column :conversation_mutes, :account_id, :integer
    change_column :conversation_mutes, :id, :integer
  end
end
