# frozen_string_literal: true

class AddBackLanguagesIndexToAccountSummaries < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :account_summaries, [:account_id, :language, :sensitive], algorithm: :concurrently
  end
end
