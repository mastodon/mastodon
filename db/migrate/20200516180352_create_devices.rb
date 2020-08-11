class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.references :access_token, foreign_key: { to_table: :oauth_access_tokens, on_delete: :cascade, index: :unique }
      t.references :account, foreign_key: { on_delete: :cascade }
      t.string :device_id, default: '', null: false
      t.string :name, default: '', null: false
      t.text :fingerprint_key, default: '', null: false
      t.text :identity_key, default: '', null: false

      t.timestamps
    end
  end
end
