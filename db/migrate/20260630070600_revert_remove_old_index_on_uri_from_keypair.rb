# frozen_string_literal: true

class RevertRemoveOldIndexOnUriFromKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    return if index_exists?(:keypairs, :uri, name: :index_keypairs_on_uri)

    add_index :keypairs, :uri, name: :index_keypairs_on_uri, unique: true, algorithm: :concurrently
  end

  def down; end
end
