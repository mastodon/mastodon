# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexMediaAttachmentsScheduledStatusId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :media_attachments, 'index_media_attachments_on_scheduled_status_id', :scheduled_status_id, where: 'scheduled_status_id IS NOT NULL'
  end

  def down
    update_index :media_attachments, 'index_media_attachments_on_scheduled_status_id', :scheduled_status_id
  end
end
