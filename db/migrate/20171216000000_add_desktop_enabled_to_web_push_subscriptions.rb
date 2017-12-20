require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddDesktopEnabledToWebPushSubscriptions < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def change
    safety_assured do
      add_column_with_default :web_push_subscriptions, :desktop_enabled, :boolean, default: true
    end
  end
end
