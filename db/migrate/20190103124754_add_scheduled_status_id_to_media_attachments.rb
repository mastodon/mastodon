class AddScheduledStatusIdToMediaAttachments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :media_attachments, :scheduled_status, foreign_key: { on_delete: :nullify }, index: false
    add_index :media_attachments, :scheduled_status_id, algorithm: :concurrently
  end
end
