require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddLockVersionToAccountStats < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :account_stats, :lock_version, :integer, allow_null: false, default: 0 }
  end

  def down
    remove_column :account_stats, :lock_version
  end
end
