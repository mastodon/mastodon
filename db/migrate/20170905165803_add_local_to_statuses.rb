class AddLocalToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :local, :boolean, null: false, default: false
  end
end
