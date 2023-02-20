class AddIndexOnMediaAttachmentsAccountIdStatusId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :media_attachments, %i(account_id status_id), order: { status_id: :desc }, algorithm: :concurrently
    remove_index :media_attachments, :account_id, algorithm: :concurrently
  end

  def down
    add_index :media_attachments, :account_id, algorithm: :concurrently
    remove_index :media_attachments, %i(account_id status_id), order: { status_id: :desc }, algorithm: :concurrently
  end
end
