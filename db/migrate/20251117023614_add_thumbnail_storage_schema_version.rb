# frozen_string_literal: true

class AddThumbnailStorageSchemaVersion < ActiveRecord::Migration[8.0]
  def change
    add_column :media_attachments, :thumbnail_storage_schema_version, :integer
  end
end
