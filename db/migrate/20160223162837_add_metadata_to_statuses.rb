class AddMetadataToStatuses < ActiveRecord::Migration[4.2]
  def change
    add_column :statuses, :in_reply_to_id, :integer, null: true
    add_column :statuses, :reblog_of_id, :integer, null: true
  end
end
