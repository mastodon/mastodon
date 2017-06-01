class AddIndexOnMediaAttachmentsAccountId < ActiveRecord::Migration[5.1]
  def change
    add_index :media_attachments, :account_id
  end
end
