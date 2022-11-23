# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexOauthAccessTokensResourceOwnerId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :oauth_access_tokens, 'index_oauth_access_tokens_on_resource_owner_id', :resource_owner_id, where: 'resource_owner_id IS NOT NULL'
  end

  def down
    update_index :oauth_access_tokens, 'index_oauth_access_tokens_on_resource_owner_id', :resource_owner_id
  end
end
