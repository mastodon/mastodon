# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexOauthAccessTokensRefreshToken < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :oauth_access_tokens, 'index_oauth_access_tokens_on_refresh_token', :refresh_token, unique: true, where: 'refresh_token IS NOT NULL', opclass: :text_pattern_ops
  end

  def down
    update_index :oauth_access_tokens, 'index_oauth_access_tokens_on_refresh_token', :refresh_token, unique: true
  end
end
