class CreateCircleAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :circle_accounts do |t|
      t.belongs_to :circle, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :follow, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end

    add_index :circle_accounts, [:account_id, :circle_id], unique: true
    add_index :circle_accounts, [:circle_id, :account_id]
  end
end
