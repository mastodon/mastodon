# frozen_string_literal: true

class AddHideNotificationsToMute < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    add_column :mutes, :hide_notifications, :boolean, default: true, null: false
  end

  def down
    remove_column :mutes, :hide_notifications
  end
end
