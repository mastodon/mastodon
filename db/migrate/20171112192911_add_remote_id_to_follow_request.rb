class AddRemoteIdToFollowRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :follow_requests, :remote_id, :string
  end
end
