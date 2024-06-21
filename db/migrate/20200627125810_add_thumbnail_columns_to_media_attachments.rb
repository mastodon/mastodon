# frozen_string_literal: true

class AddThumbnailColumnsToMediaAttachments < ActiveRecord::Migration[5.2]
  def up
    # The following corresponds to `add_attachment :media_attachments, :thumbnail` in an older version of Paperclip
    safety_assured do
      change_table :media_attachments, bulk: true do |t|
        t.string :thumbnail_file_name
        t.string :thumbnail_content_type
        t.integer :thumbnail_file_size
        t.datetime :thumbnail_updated_at

        t.string :thumbnail_remote_url
      end
    end
  end

  def down
    remove_attachment :media_attachments, :thumbnail
    remove_column :media_attachments, :thumbnail_remote_url
  end
end
