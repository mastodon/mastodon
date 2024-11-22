# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexListAccountsFollowId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :list_accounts, 'index_list_accounts_on_follow_id', :follow_id, where: 'follow_id IS NOT NULL'
  end

  def down
    update_index :list_accounts, 'index_list_accounts_on_follow_id', :follow_id
  end
end
