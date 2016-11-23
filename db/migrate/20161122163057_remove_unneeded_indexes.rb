class RemoveUnneededIndexes < ActiveRecord::Migration[5.0]
  def change
    remove_index :notifications, name: "index_notifications_on_account_id"
    remove_index :settings, name: "index_settings_on_target_type_and_target_id"
    remove_index :statuses_tags, name: "index_statuses_tags_on_tag_id"
  end
end
