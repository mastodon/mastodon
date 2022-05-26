# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexStatusesInReplyToAccountId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :statuses, 'index_statuses_on_in_reply_to_account_id', :in_reply_to_account_id, where: 'in_reply_to_account_id IS NOT NULL'
  end

  def down
    update_index :statuses, 'index_statuses_on_in_reply_to_account_id', :in_reply_to_account_id
  end
end
