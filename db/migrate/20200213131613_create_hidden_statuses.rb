class CreateHiddenStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :hidden_statuses do |t|
      t.references :account, null: false
      t.references :status, null: false

      t.timestamps
    end

    safety_assured do
      add_foreign_key :hidden_statuses, :accounts, column: :account_id, on_delete: :cascade
      add_foreign_key :hidden_statuses, :statuses, column: :status_id, on_delete: :cascade
    end

    add_index :hidden_statuses, [:account_id, :status_id], unique: true
  end
end
