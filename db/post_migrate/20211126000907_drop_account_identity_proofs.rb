# frozen_string_literal: true

class DropAccountIdentityProofs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    drop_table :account_identity_proofs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
