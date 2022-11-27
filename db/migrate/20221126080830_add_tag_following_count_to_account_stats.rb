require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddTagFollowingCountToAccountStats < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :account_stats, :tag_following_count, :bigint, allow_null: false, default: 0
      execute 'UPDATE account_stats ' \
              'SET tag_following_count = ( ' \
              '  SELECT COUNT(account_id) ' \
              '  FROM tag_follows ' \
              '  WHERE tag_follows.account_id = account_stats.account_id ' \
              '  GROUP BY account_id ' \
              ');'
    end
  end

  def down
    remove_column :account_stats, :tag_following_count
  end
end
