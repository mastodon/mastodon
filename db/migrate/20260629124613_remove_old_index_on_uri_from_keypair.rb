# frozen_string_literal: true

class RemoveOldIndexOnUriFromKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :keypairs, :uri, name: :index_keypairs_on_uri, unique: true, algorithm: :concurrently
  end
end
