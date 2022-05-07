# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexAccountMigrationsTargetAccountId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :account_migrations, 'index_account_migrations_on_target_account_id', :target_account_id, where: 'target_account_id IS NOT NULL'
  end

  def down
    update_index :account_migrations, 'index_account_migrations_on_target_account_id', :target_account_id
  end
end
