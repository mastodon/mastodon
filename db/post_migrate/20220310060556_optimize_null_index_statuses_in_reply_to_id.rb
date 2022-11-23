# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexStatusesInReplyToId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :statuses, 'index_statuses_on_in_reply_to_id', :in_reply_to_id, where: 'in_reply_to_id IS NOT NULL'
  end

  def down
    update_index :statuses, 'index_statuses_on_in_reply_to_id', :in_reply_to_id
  end
end
