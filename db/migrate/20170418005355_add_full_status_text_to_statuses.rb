class AddFullStatusTextToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :full_status_text, :text, default: "", null: false
  end
end
