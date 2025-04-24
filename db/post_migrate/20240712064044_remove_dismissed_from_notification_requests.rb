# frozen_string_literal: true

class RemoveDismissedFromNotificationRequests < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute 'DELETE FROM notification_requests WHERE dismissed'
      remove_column :notification_requests, :dismissed
    end
  end

  def down
    add_column :notification_requests, :dismissed, :boolean, default: false, null: false
  end
end
