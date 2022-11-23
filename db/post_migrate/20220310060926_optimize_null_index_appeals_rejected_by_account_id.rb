# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexAppealsRejectedByAccountId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :appeals, 'index_appeals_on_rejected_by_account_id', :rejected_by_account_id, where: 'rejected_by_account_id IS NOT NULL'
  end

  def down
    update_index :appeals, 'index_appeals_on_rejected_by_account_id', :rejected_by_account_id
  end
end
