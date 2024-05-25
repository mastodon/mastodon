# frozen_string_literal: true

class RemoveUnusedIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :statuses, name: 'index_statuses_on_conversation_id'
    remove_index :users, name: 'index_users_on_filtered_languages'
    remove_index :backups, name: 'index_backups_on_user_id'
  end
end
