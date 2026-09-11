# frozen_string_literal: true

class AddLastUsedAtToOAuthAccessTokens < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:oauth_access_tokens, bulk: true) do |t|
        t.column :last_used_at, :datetime
        t.column :last_used_ip, :inet
      end
    end
  end
end
