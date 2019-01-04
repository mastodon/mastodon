class CreateIdentities < ActiveRecord::Migration[5.0]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false, default: ''
      t.string :uid, null: false, default: ''

      t.timestamps
    end
  end
end
