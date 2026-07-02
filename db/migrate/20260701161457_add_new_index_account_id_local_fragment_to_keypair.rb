# frozen_string_literal: true

class AddNewIndexAccountIdLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :keypairs, [:account_id, :local_fragment], unique: true, name: :index_keypairs_on_account_id_and_local_fragment, algorithm: :concurrently
  end
end
