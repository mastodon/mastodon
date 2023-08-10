# frozen_string_literal: true

class AddTypeToMediaAttachments < ActiveRecord::Migration[5.0]
  class MigrationMediaAttachment < ApplicationRecord
    self.table_name = :media_attachments
    enum type: [:image, :gifv, :video]
    IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
    VIDEO_MIME_TYPES = ['video/webm', 'video/mp4'].freeze
  end

  def up
    add_column :media_attachments, :type, :integer, default: 0, null: false

    MigrationMediaAttachment.reset_column_information

    MigrationMediaAttachment
      .where(file_content_type: MigrationMediaAttachment::IMAGE_MIME_TYPES)
      .update_all(type: MigrationMediaAttachment.types[:image])
    MigrationMediaAttachment
      .where(file_content_type: MigrationMediaAttachment::VIDEO_MIME_TYPES)
      .update_all(type: MigrationMediaAttachment.types[:video])
  end

  def down
    remove_column :media_attachments, :type
  end
end
