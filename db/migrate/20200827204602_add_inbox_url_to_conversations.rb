class AddInboxURLToConversations < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :parent_status_id, :bigint, null: true, default: nil
    add_column :conversations, :parent_account_id, :bigint, null: true, default: nil
    add_column :conversations, :inbox_url, :string, null: true, default: nil
  end
end
