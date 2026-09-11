# frozen_string_literal: true

class AddProfileSettingsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :show_media, :boolean, null: false, default: true
    add_column :accounts, :show_media_replies, :boolean, null: false, default: true
    add_column :accounts, :show_featured, :boolean, null: false, default: true
  end
end
