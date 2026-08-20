# frozen_string_literal: true

class RenameIndexAccountIdLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  def change
    rename_index :keypairs, 'index_keypairs_on_account_id_and_local_fragment', 'old_index_keypairs_on_account_id_and_local_fragment'
  end
end
