require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddMediaUploadsEnabledToAccounts < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :accounts, :media_uploads_disabled, :bool, default: false }
  end

  def down
    remove_column :accounts, :media_uploads_disabled
  end
end
