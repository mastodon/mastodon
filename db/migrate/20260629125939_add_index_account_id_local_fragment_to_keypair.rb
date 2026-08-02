# frozen_string_literal: true

class AddIndexAccountIdLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :keypairs, [:account_id, :local_fragment], unique: true, where: 'local_fragment IS NOT NULL', algorithm: :concurrently
  end
end
