# frozen_string_literal: true

class AddTargetAccountIndexToFollowRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :follow_requests, [:target_account_id, :account_id], algorithm: :concurrently
  end
end
