class CreateReportNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :report_notes do |t|
      t.text :content, null: false
      t.references :report, null: false
      t.references :account, null: false

      t.timestamps
    end

    add_foreign_key :report_notes, :reports, column: :report_id, on_delete: :cascade
    add_foreign_key :report_notes, :accounts, column: :account_id, on_delete: :cascade
  end
end
