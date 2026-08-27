# frozen_string_literal: true

class AddIndexAccountIdLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index :keypairs, [:account_id, :local_fragment], unique: true, where: 'local_fragment IS NOT NULL', algorithm: :concurrently
  rescue ActiveRecord::StatementInvalid
    safety_assured { execute 'REINDEX INDEX CONCURRENTLY index_keypairs_on_account_id_and_local_fragment' }
  end

  def down
    remove_index :keypairs, name: :index_keypairs_on_account_id_and_local_fragment
  end
end
