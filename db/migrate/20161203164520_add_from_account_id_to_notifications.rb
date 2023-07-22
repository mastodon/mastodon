# frozen_string_literal: true

class AddFromAccountIdToNotifications < ActiveRecord::Migration[5.0]
  def up
    add_column :notifications, :from_account_id, :integer

    Notification.where(from_account_id: nil).where(activity_type: 'Status').update_all('from_account_id = (SELECT statuses.account_id FROM notifications AS notifications1 INNER JOIN statuses ON notifications1.activity_id = statuses.id WHERE notifications1.activity_type = \'Status\' AND notifications1.id = notifications.id)')
    Notification.where(from_account_id: nil).where(activity_type: 'Mention').update_all('from_account_id = (SELECT statuses.account_id FROM notifications AS notifications1 INNER JOIN mentions ON notifications1.activity_id = mentions.id INNER JOIN statuses ON mentions.status_id = statuses.id WHERE notifications1.activity_type = \'Mention\' AND notifications1.id = notifications.id)')
    Notification.where(from_account_id: nil).where(activity_type: 'Favourite').update_all('from_account_id = (SELECT favourites.account_id FROM notifications AS notifications1 INNER JOIN favourites ON notifications1.activity_id = favourites.id WHERE notifications1.activity_type = \'Favourite\' AND notifications1.id = notifications.id)')
    Notification.where(from_account_id: nil).where(activity_type: 'Follow').update_all('from_account_id = (SELECT follows.account_id FROM notifications AS notifications1 INNER JOIN follows ON notifications1.activity_id = follows.id WHERE notifications1.activity_type = \'Follow\' AND notifications1.id = notifications.id)')
  end

  def down
    remove_column :notifications, :from_account_id
  end
end
