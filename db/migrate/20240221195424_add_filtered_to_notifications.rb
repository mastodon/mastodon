# frozen_string_literal: true

class AddFilteredToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :filtered, :boolean, default: false, null: false
  end
end
