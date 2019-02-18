class UpdateAccountIdentityProofsColumnNames < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
        rename_column :account_identity_proofs, :is_live, :proof_live
        rename_column :account_identity_proofs, :is_valid, :proof_valid
    end
  end
end
