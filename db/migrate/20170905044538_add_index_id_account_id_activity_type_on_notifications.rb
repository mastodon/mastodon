class AddIndexIdAccountIdActivityTypeOnNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :notifications, [:id, :account_id, :activity_type], order: { id: :desc }
  end
end
