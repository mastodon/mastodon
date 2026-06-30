# frozen_string_literal: true

require_relative '20260629124055_add_new_index_on_uri_to_keypairs'

class RevertAddNewIndexOnUriToKeypairs < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    revert AddNewIndexOnUriToKeypairs
  end
end
