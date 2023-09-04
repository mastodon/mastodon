class CreateAccountPins < ActiveRecord::Migration[5.2]
  def change
    create_table :account_pins do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.belongs_to :target_account, foreign_key: { on_delete: :cascade, to_table: :accounts }

      t.timestamps
    end

    add_index :account_pins, [:account_id, :target_account_id], unique: true
  end
end
