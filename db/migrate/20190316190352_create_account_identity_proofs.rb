class CreateAccountIdentityProofs < ActiveRecord::Migration[5.2]
  def change
    create_table :account_identity_proofs do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false, default: ''
      t.string :provider_username, null: false, default: ''
      t.text :token, null: false, default: ''
      t.boolean :verified, null: false, default: false
      t.boolean :live, null: false, default: false

      t.timestamps null: false
    end

    add_index :account_identity_proofs, %i(account_id provider provider_username), unique: true, name: :index_account_proofs_on_account_and_provider_and_username
  end
end
