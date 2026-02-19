# frozen_string_literal: true

class ChangePrimaryKeyToBigintOnStatuses < ActiveRecord::Migration[5.0]
  def up
    change_table(:statuses, bulk: true) do |t|
      t.change :id, :bigint
      t.change :reblog_of_id, :bigint
      t.change :in_reply_to_id, :bigint
    end

    change_column :media_attachments, :status_id, :bigint
    change_column :mentions, :status_id, :bigint
    change_column :notifications, :activity_id, :bigint
    change_column :preview_cards, :status_id, :bigint
    change_column :reports, :status_ids, :bigint, array: true
    change_column :statuses_tags, :status_id, :bigint
    change_column :stream_entries, :activity_id, :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
