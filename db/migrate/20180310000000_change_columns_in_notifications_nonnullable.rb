class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :notifications, :activity_id, false
      change_column_null :notifications, :activity_type, false
      change_column_null :notifications, :account_id, false
      change_column_null :notifications, :from_account_id, false
    end
  end
end
