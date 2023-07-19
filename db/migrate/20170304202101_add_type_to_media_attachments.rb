# frozen_string_literal: true

class AddTypeToMediaAttachments < ActiveRecord::Migration[5.0]
  def up
    add_column :media_attachments, :type, :integer, default: 0, null: false

    MediaAttachment.where(file_content_type: MediaAttachment::IMAGE_MIME_TYPES).update_all(type: MediaAttachment.types[:image])
    MediaAttachment.where(file_content_type: MediaAttachment::VIDEO_MIME_TYPES).update_all(type: MediaAttachment.types[:video])
  end

  def down
    remove_column :media_attachments, :type
  end
end
