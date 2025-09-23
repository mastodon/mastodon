# frozen_string_literal: true

class AddIndexOnConversationToStatuses < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :statuses, :conversation_id, algorithm: :concurrently
  end
end
