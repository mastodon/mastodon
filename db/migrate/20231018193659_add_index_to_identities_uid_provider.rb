# frozen_string_literal: true

class AddIndexToIdentitiesUidProvider < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :identities, [:uid, :provider], unique: true, algorithm: :concurrently
  end
end
