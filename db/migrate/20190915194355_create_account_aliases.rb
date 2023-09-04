class CreateAccountAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :account_aliases do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.string :acct, null: false, default: ''
      t.string :uri, null: false, default: ''

      t.timestamps
    end
  end
end
