class AddOrderedMediaAttachmentIdsToStatusEdits < ActiveRecord::Migration[6.1]
  def change
    add_column :status_edits, :ordered_media_attachment_ids, :bigint, array: true
    add_column :status_edits, :media_descriptions, :text, array: true
    add_column :status_edits, :poll_options, :string, array: true
    add_column :status_edits, :sensitive, :boolean
  end
end
