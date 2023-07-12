# frozen_string_literal: true

class AddStorageSchemaVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :preview_cards, :image_storage_schema_version, :integer
    add_column :accounts, :avatar_storage_schema_version, :integer
    add_column :accounts, :header_storage_schema_version, :integer
    add_column :media_attachments, :file_storage_schema_version, :integer
    add_column :custom_emojis, :image_storage_schema_version, :integer
  end
end
