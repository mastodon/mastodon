class AddTypeToNotifications < ActiveRecord::Migration[5.1]
  def up
    add_column :notifications, :type, :string
    Notification.where(activity_type: 'Mention').update_all(type: 'mention')
    Notification.where(activity_type: 'Status').update_all(type: 'reblog')
    Notification.where(activity_type: 'Follow').update_all(type: 'follow')
    Notification.where(activity_type: 'FollowRequest').update_all(type: 'follow_request')
    Notification.where(activity_type: 'Favourite').update_all(type: 'favourite')
    change_column_null :notifications, :type, false
  end

  def down
    remove_column :notifications, :type
  end
end
