class CreateListAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :list_accounts do |t|
      t.belongs_to :list, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :follow, foreign_key: { on_delete: :cascade }, null: false
    end

    add_index :list_accounts, %i(account_id list_id), unique: true
    add_index :list_accounts, %i(list_id account_id)
  end
end
