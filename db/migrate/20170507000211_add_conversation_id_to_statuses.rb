# frozen_string_literal: true

class AddConversationIdToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :conversation_id, :bigint, null: true, default: nil
    add_index :statuses, :conversation_id
  end
end
