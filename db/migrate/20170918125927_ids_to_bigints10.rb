class IdsToBigints10 < ActiveRecord::Migration[5.1]
  def up
    change_column :media_attachments, :account_id, :bigint
    change_column :media_attachments, :id, :bigint
  end

  def down
    change_column :media_attachments, :account_id, :integer
    change_column :media_attachments, :id, :integer
  end
end
