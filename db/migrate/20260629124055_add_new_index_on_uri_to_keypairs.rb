# frozen_string_literal: true

class AddNewIndexOnUriToKeypairs < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :keypairs, :uri, name: :index_keypairs_on_non_null_uri, unique: true, where: 'uri IS NOT NULL', algorithm: :concurrently
  end
end
