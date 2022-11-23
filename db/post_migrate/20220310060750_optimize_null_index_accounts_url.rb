# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexAccountsURL < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :accounts, 'index_accounts_on_url', :url, where: 'url IS NOT NULL', opclass: :text_pattern_ops
  end

  def down
    update_index :accounts, 'index_accounts_on_url', :url
  end
end
