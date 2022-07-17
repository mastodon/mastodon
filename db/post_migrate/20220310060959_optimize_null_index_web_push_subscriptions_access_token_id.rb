# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexWebPushSubscriptionsAccessTokenId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :web_push_subscriptions, 'index_web_push_subscriptions_on_access_token_id', :access_token_id, where: 'access_token_id IS NOT NULL'
  end

  def down
    update_index :web_push_subscriptions, 'index_web_push_subscriptions_on_access_token_id', :access_token_id
  end
end
