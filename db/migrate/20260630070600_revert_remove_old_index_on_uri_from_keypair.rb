# frozen_string_literal: true

require_relative '20260629124613_remove_old_index_on_uri_from_keypair'

class RevertRemoveOldIndexOnUriFromKeypair < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    revert RemoveOldIndexOnUriFromKeypair
  end
end
