# frozen_string_literal: true

class RemoveIndexKeypairsOnAccountId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :keypairs, :account_id, algorithm: :concurrently
  end
end
