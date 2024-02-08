# frozen_string_literal: true

class AddStorageSchemaVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :preview_cards, :image_storage_schema_version, :integer
    safety_assured do
      change_table(:accounts, bulk: true) do |t|
        t.column :avatar_storage_schema_version, :integer
        t.column :header_storage_schema_version, :integer
      end
    end
    add_column :media_attachments, :file_storage_schema_version, :integer
    add_column :custom_emojis, :image_storage_schema_version, :integer
  end
end
