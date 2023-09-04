class ChangePrimaryKeyToBigintOnStatuses < ActiveRecord::Migration[5.0]
  def change
    change_column :statuses, :id, :bigint
    change_column :statuses, :reblog_of_id, :bigint
    change_column :statuses, :in_reply_to_id, :bigint

    change_column :media_attachments, :status_id, :bigint
    change_column :mentions, :status_id, :bigint
    change_column :notifications, :activity_id, :bigint
    change_column :preview_cards, :status_id, :bigint
    change_column :reports, :status_ids, :bigint, array: true
    change_column :statuses_tags, :status_id, :bigint
    change_column :stream_entries, :activity_id, :bigint
  end
end
