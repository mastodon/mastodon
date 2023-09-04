class AddSensitiveToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :sensitive, :boolean, default: false
  end
end
