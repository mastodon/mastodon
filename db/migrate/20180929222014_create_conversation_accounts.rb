class CreateConversationAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :conversation_accounts do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, index: true
      t.belongs_to :conversation, foreign_key: { on_delete: :cascade }
      t.bigint :participant_account_ids, array: true, null: false, default: []
      t.bigint :status_ids, array: true, null: false, default: []
      t.belongs_to :last_status, foreign_key: { on_delete: :nullify, to_table: :statuses }
    end

    add_index :conversation_accounts, [:account_id, :conversation_id, :participant_account_ids], unique: true, name: 'index_unique_conversations'
  end
end
