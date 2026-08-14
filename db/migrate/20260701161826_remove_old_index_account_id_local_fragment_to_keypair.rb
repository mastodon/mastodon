# frozen_string_literal: true

class RemoveOldIndexAccountIdLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :keypairs, [:account_id, :local_fragment], name: :old_index_keypairs_on_account_id_and_local_fragment, unique: true, where: 'local_fragment IS NOT NULL', algorithm: :concurrently
  end
end
