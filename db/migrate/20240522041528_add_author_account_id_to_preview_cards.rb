# frozen_string_literal: true

class AddAuthorAccountIdToPreviewCards < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :preview_cards, :author_account, null: true, foreign_key: { to_table: 'accounts', on_delete: :nullify }, index: false }
    add_index :preview_cards, :author_account_id, algorithm: :concurrently, where: 'author_account_id IS NOT NULL'
  end
end
