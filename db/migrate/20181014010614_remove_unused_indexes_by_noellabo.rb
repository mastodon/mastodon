class RemoveUnusedIndexesByNoellabo < ActiveRecord::Migration[5.2]
  def change
    remove_index :pghero_space_stats, name: "index_pghero_space_stats_on_database_and_captured_at"
    remove_index :account_conversations, name: "index_account_conversations_on_account_id"
    remove_index :account_conversations, name: "index_account_conversations_on_conversation_id"
    remove_index :account_pins, name: "index_account_pins_on_account_id"
    remove_index :admin_action_logs, name: "index_admin_action_logs_on_target_type_and_target_id"
    remove_index :list_accounts, name: "index_list_accounts_on_list_id_and_account_id"
    remove_index :report_notes, name: "index_report_notes_on_report_id"
  end
end
