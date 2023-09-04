class CreateStatusPins < ActiveRecord::Migration[5.1]
  def change
    create_table :status_pins do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :status, foreign_key: { on_delete: :cascade }, null: false
    end

    add_index :status_pins, [:account_id, :status_id], unique: true
  end
end
