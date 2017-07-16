class AddHideNotificationsToMute < ActiveRecord::Migration[5.1]
  def change
    add_column :mutes, :hide_notifications, :boolean, default: false, null: false
  end
end
