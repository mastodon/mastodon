# frozen_string_literal: true

require_relative '../../lib/mastodon/migration_helpers'

class ConvertFileSizeColumnsToBigInt < ActiveRecord::Migration[7.1]
  include Mastodon::MigrationHelpers

  TABLE_COLUMN_MAPPING = [
    [:accounts, :avatar_file_size],
    [:accounts, :header_file_size],
    [:custom_emojis, :image_file_size],
    [:imports, :data_file_size],
    [:media_attachments, :file_file_size],
    [:media_attachments, :thumbnail_file_size],
    [:preview_cards, :image_file_size],
    [:site_uploads, :file_file_size],
  ].freeze

  disable_ddl_transaction!

  def migrate_columns(to_type)
    TABLE_COLUMN_MAPPING.each do |column_parts|
      table, column = column_parts

      # Skip this if we're resuming and already did this one.
      next if column_for(table, column).sql_type == to_type.to_s

      safety_assured do
        change_column_type_concurrently table, column, to_type
        cleanup_concurrent_column_type_change table, column
      end
    end
  end

  def up
    migrate_columns(:bigint)
  end

  def down
    migrate_columns(:integer)
  end
end
