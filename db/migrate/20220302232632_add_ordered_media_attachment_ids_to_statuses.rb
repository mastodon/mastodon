class AddOrderedMediaAttachmentIdsToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :ordered_media_attachment_ids, :bigint, array: true
  end
end
