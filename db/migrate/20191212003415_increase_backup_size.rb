# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IncreaseBackupSize < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      change_column_type_concurrently :backups, :dump_file_size, :bigint
      cleanup_concurrent_column_type_change :backups, :dump_file_size
    end
  end

  def down
    safety_assured do
      change_column_type_concurrently :backups, :dump_file_size, :integer
      cleanup_concurrent_column_type_change :backups, :dump_file_size
    end
  end
end
