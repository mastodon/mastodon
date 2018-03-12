require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddLastReadNotificationIdToUsers < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def change
    add_column :users, :last_read_notification_id, :bigint

    reversible do |dir|
      dir.up do
        safety_assured do
          add_column_with_default :oauth_access_tokens, :reading_notifications, :boolean, allow_null: false, default: false
          update_column_in_batches :users, :last_read_notification_id, 9e9
        end

        change_column_null :users, :last_read_notification_id, false
        change_column_default :users, :last_read_notification_id, 0
      end

      dir.down { remove_column :oauth_access_tokens, :reading_notifications }
    end
  end
end
