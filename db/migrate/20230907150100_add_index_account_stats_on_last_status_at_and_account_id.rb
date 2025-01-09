# frozen_string_literal: true

class AddIndexAccountStatsOnLastStatusAtAndAccountId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :account_stats, [:last_status_at, :account_id], order: { last_status_at: 'DESC NULLS LAST' }, algorithm: :concurrently
  end
end
