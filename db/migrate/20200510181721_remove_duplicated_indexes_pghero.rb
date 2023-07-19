# frozen_string_literal: true

class RemoveDuplicatedIndexesPghero < ActiveRecord::Migration[5.2]
  def up
    remove_index :account_conversations, name: :index_account_conversations_on_account_id     if index_exists?(:account_conversations, :account_id, name: :index_account_conversations_on_account_id)
    remove_index :account_identity_proofs, name: :index_account_identity_proofs_on_account_id if index_exists?(:account_identity_proofs, :account_id, name: :index_account_identity_proofs_on_account_id)
    remove_index :account_pins, name: :index_account_pins_on_account_id                       if index_exists?(:account_pins, :account_id, name: :index_account_pins_on_account_id)
    remove_index :announcement_mutes, name: :index_announcement_mutes_on_account_id           if index_exists?(:announcement_mutes, :account_id, name: :index_announcement_mutes_on_account_id)
    remove_index :announcement_reactions, name: :index_announcement_reactions_on_account_id   if index_exists?(:announcement_reactions, :account_id, name: :index_announcement_reactions_on_account_id)
    remove_index :bookmarks, name: :index_bookmarks_on_account_id                             if index_exists?(:bookmarks, :account_id, name: :index_bookmarks_on_account_id)
    remove_index :markers, name: :index_markers_on_user_id                                    if index_exists?(:markers, :user_id, name: :index_markers_on_user_id)
  end

  def down
    add_index :account_conversations, :account_id, name: :index_account_conversations_on_account_id     unless index_exists?(:account_conversations, :account_id, name: :index_account_conversations_on_account_id)
    add_index :account_identity_proofs, :account_id, name: :index_account_identity_proofs_on_account_id unless index_exists?(:account_identity_proofs, :account_id, name: :index_account_identity_proofs_on_account_id)
    add_index :account_pins, :account_id, name: :index_account_pins_on_account_id                       unless index_exists?(:account_pins, :account_id, name: :index_account_pins_on_account_id)
    add_index :announcement_mutes, :account_id, name: :index_announcement_mutes_on_account_id           unless index_exists?(:announcement_mutes, :account_id, name: :index_announcement_mutes_on_account_id)
    add_index :announcement_reactions, :account_id, name: :index_announcement_reactions_on_account_id   unless index_exists?(:announcement_reactions, :account_id, name: :index_announcement_reactions_on_account_id)
    add_index :bookmarks, :account_id, name: :index_bookmarks_on_account_id                             unless index_exists?(:bookmarks, :account_id, name: :index_bookmarks_on_account_id)
    add_index :markers, :user_id, name: :index_markers_on_user_id                                       unless index_exists?(:markers, :user_id, name: :index_markers_on_user_id)
  end
end
