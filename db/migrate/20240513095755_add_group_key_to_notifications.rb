# frozen_string_literal: true

class AddGroupKeyToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :group_key, :string
  end
end
