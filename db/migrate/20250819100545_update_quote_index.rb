# frozen_string_literal: true

class UpdateQuoteIndex < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :quotes, [:account_id, :quoted_account_id, :id], algorithm: :concurrently
    remove_index :quotes, [:account_id, :quoted_account_id]

    add_index :quotes, [:quoted_status_id, :id], algorithm: :concurrently
    remove_index :quotes, [:quoted_status_id]
  end
end
