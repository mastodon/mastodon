# frozen_string_literal: true

class RemoveIndexFollowsOnTargetAccountId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_index :follows, [:target_account_id], algorithm: :concurrently
  end
end
