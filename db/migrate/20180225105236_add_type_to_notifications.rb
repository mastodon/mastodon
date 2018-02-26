class AddTypeToNotifications < ActiveRecord::Migration[5.1]
  def up
    add_column :notifications, :type, :string
    activity_type_map = Notification.const_get(:ACTIVITY_TYPE_DEFAULT_MAP)
    Notification.find_in_batches(batch_size: 1000) do |notifications|
      notifications.group_by(&:activity_type).each do |activity_type,ary|
        Notification.where(id: ary.map(&:id)).update_all(type: activity_type_map[activity_type])
      end
    end
    change_column_null :notifications, :type, false
  end

  def down
    remove_column :notifications, :type
  end
end
