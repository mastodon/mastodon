# frozen_string_literal: true

class RemoveRevertedConversationChanges < ActiveRecord::Migration[8.0]
  def up
    remove_index :statuses, :conversation_id if index_exists?(:statuses, :conversation_id)
    safety_assured { remove_column :conversations, :parent_status_id, if_exists: true }
    safety_assured { remove_column :conversations, :parent_account_id, if_exists: true }
  end

  def down; end
end
