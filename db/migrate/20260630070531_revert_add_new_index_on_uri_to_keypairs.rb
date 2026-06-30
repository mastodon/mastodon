# frozen_string_literal: true

class RevertAddNewIndexOnUriToKeypairs < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    return unless index_exists?(:keypairs, :uri, name: :index_keypairs_on_non_null_uri)

    remove_index :keypairs, :uri, name: :index_keypairs_on_non_null_uri
  end

  def down; end
end
