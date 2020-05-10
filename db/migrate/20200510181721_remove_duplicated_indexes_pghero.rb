class RemoveDuplicatedIndexesPghero < ActiveRecord::Migration[5.2]
  def change
    remove_index :account_conversations, name: "index_account_conversations_on_account_id", column: :account_id
    remove_index :account_identity_proofs, name: "index_account_identity_proofs_on_account_id", column: :account_id
    remove_index :account_pins, name: "index_account_pins_on_account_id", column: :account_id
    remove_index :announcement_mutes, name: "index_announcement_mutes_on_account_id", column: :account_id
    remove_index :announcement_reactions, name: "index_announcement_reactions_on_account_id", column: :account_id
    remove_index :bookmarks, name: "index_bookmarks_on_account_id", column: :account_id
    remove_index :markers, name: "index_markers_on_user_id", column: :user_id
  end
end

