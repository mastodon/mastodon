# frozen_string_literal: true

class AddUnverifiedAuthorAccountIdToPreviewCards < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :preview_cards, :unverified_author_account, null: true, foreign_key: { to_table: 'accounts', on_delete: :nullify }, index: false }
    add_index :preview_cards, [:unverified_author_account_id, :id], algorithm: :concurrently, where: 'unverified_author_account_id IS NOT NULL'
  end
end
