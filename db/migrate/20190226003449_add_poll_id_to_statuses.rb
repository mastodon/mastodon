class AddPollIdToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :poll_id, :bigint
  end
end
