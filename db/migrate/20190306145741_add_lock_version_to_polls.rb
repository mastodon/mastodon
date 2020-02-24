require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddLockVersionToPolls < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default(
        :polls,
        :lock_version,
        :integer,
        allow_null: false,
        default: 0
      )
    end
  end

  def down
    remove_column :polls, :lock_version
  end
end

