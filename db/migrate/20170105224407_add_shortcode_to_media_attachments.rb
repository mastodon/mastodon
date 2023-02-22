# frozen_string_literal: true

class AddShortcodeToMediaAttachments < ActiveRecord::Migration[5.0]
  def up
    add_column :media_attachments, :shortcode, :string, null: true, default: nil
    add_index :media_attachments, :shortcode, unique: true

    # Migrate old links
    MediaAttachment.local.update_all('shortcode = id')
  end

  def down
    remove_index :media_attachments, :shortcode
    remove_column :media_attachments, :shortcode
  end
end
