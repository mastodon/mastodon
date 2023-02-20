class AddIndexIdAccountIdActivityTypeOnNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :notifications, %i(id account_id activity_type), order: { id: :desc }
  end
end
