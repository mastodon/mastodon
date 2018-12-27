class CreateAccountIdentityProofs < ActiveRecord::Migration[5.2]
  def change
    create_table :account_identity_proofs do |t|
      t.belongs_to :account, foreign_key: {on_delete: :cascade}
      t.string :provider, null: false # e.g. `keybase`
      t.string :provider_username, null: false
      t.text :token, null: false
      t.boolean :is_valid
      t.boolean :is_live

      t.timestamps null: false
    end
    add_index :account_identity_proofs,
      [:account_id, :provider, :provider_username],
      unique: true,
      name: :index_account_proofs_on_account_and_provider_and_username
  end
end
