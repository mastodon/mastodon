class AddRemoteUrlToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :remote_url, :string
  end
end
