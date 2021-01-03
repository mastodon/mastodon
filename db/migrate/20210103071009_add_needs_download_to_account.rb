require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddNeedsDownloadToAccount < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :accounts, :avatar_needs_download, :boolean, default: false
      add_column_with_default :accounts, :header_needs_download, :boolean, default: false
    end
  end

  def down
    remove_column :accounts, :avatar_needs_download
    remove_column :accounts, :header_needs_download
  end
end
