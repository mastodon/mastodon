# frozen_string_literal: true

class AddThumbnailColumnsToMediaAttachments < ActiveRecord::Migration[5.2]
  def up
    # The following corresponds to `add_attachment :media_attachments, :thumbnail` in an older version of Paperclip
    add_column :media_attachments, :thumbnail_file_name, :string
    add_column :media_attachments, :thumbnail_content_type, :string
    add_column :media_attachments, :thumbnail_file_size, :integer
    add_column :media_attachments, :thumbnail_updated_at, :datetime

    add_column :media_attachments, :thumbnail_remote_url, :string
  end

  def down
    remove_attachment :media_attachments, :thumbnail
    remove_column :media_attachments, :thumbnail_remote_url
  end
end
