# frozen_string_literal: true

class AddIndexFollowsOnTargetAccountIdAndAccountId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :follows, [:target_account_id, :account_id], algorithm: :concurrently
  end
end
