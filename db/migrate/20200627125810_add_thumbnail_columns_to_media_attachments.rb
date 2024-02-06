# frozen_string_literal: true

class AddThumbnailColumnsToMediaAttachments < ActiveRecord::Migration[5.2]
  def up
    add_attachment :media_attachments, :thumbnail
    add_column :media_attachments, :thumbnail_remote_url, :string
  end

  def down
    remove_attachment :media_attachments, :thumbnail
    remove_column :media_attachments, :thumbnail_remote_url
  end
end
