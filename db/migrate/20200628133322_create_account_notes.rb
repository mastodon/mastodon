class CreateAccountNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :account_notes do |t|
      t.references :account, foreign_key: { on_delete: :cascade }, index: false
      t.references :target_account, foreign_key: { to_table: :accounts, on_delete: :cascade }
      t.text :comment, null: false
      t.index [:account_id, :target_account_id], unique: true

      t.timestamps
    end
  end
end
