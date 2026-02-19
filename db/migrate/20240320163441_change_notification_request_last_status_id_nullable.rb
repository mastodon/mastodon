# frozen_string_literal: true

class ChangeNotificationRequestLastStatusIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notification_requests, :last_status_id, true
  end
end
