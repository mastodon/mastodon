class AddTypeToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :type, :string
  end
end
