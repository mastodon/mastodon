class AddSpoilerTextToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :spoiler_text, :text, default: ""
  end
end
