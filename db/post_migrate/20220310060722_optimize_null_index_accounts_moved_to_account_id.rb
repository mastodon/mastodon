# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexAccountsMovedToAccountId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :accounts, 'index_accounts_on_moved_to_account_id', :moved_to_account_id, where: 'moved_to_account_id IS NOT NULL'
  end

  def down
    update_index :accounts, 'index_accounts_on_moved_to_account_id', :moved_to_account_id
  end
end
