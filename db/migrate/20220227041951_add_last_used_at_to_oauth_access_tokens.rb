# frozen_string_literal: true

class AddLastUsedAtToOauthAccessTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_access_tokens, :last_used_at, :datetime
    add_column :oauth_access_tokens, :last_used_ip, :inet
  end
end
