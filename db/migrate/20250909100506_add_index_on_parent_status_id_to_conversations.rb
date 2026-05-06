# frozen_string_literal: true

class AddIndexOnParentStatusIdToConversations < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :conversations, :parent_status_id, algorithm: :concurrently, unique: true, where: 'parent_status_id IS NOT NULL'
  end
end
