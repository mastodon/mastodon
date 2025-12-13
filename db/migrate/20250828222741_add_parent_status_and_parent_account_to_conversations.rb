# frozen_string_literal: true

class AddParentStatusAndParentAccountToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :parent_status_id, :bigint, null: true, default: nil
    add_column :conversations, :parent_account_id, :bigint, null: true, default: nil
  end
end
