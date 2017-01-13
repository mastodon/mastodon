class AddSpoilerToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :spoiler, :boolean, default: false
  end
end
