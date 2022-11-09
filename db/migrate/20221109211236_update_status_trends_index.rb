require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class UpdateStatusTrendsIndex < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { update_index :status_trends, 'index_status_trends_on_account_id', [:account_id, :allowed] }
  end

  def down
    safety_assured { update_index :status_trends, 'index_status_trends_on_account_id', [:account_id] }
  end
end
