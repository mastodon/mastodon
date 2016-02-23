class AddUrlToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :url, :string, null: true, default: nil
  end
end
