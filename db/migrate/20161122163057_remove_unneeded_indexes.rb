# frozen_string_literal: true

class RemoveUnneededIndexes < ActiveRecord::Migration[5.0]
  def change
    remove_index :notifications, :account_id, name: 'index_notifications_on_account_id'
    remove_index :settings, [:target_type, :target_id], name: 'index_settings_on_target_type_and_target_id'
    remove_index :statuses_tags, :tag_id, name: 'index_statuses_tags_on_tag_id'
  end
end
