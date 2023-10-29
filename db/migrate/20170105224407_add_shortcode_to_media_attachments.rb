# frozen_string_literal: true

class AddShortcodeToMediaAttachments < ActiveRecord::Migration[5.0]
  class MigrationMediaAttachment < ApplicationRecord
    self.table_name = :media_attachments
    scope :local, -> { where(remote_url: '') }
  end

  def up
    add_column :media_attachments, :shortcode, :string, null: true, default: nil
    add_index :media_attachments, :shortcode, unique: true

    MigrationMediaAttachment.reset_column_information

    # Migrate old links
    MigrationMediaAttachment.local.update_all('shortcode = id')
  end

  def down
    remove_index :media_attachments, :shortcode
    remove_column :media_attachments, :shortcode
  end
end
