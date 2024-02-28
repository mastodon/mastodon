class CreateLocalPreviewCards < ActiveRecord::Migration[7.1]
  def change
    create_table :local_preview_cards do |t|
      t.belongs_to :status, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :target_status, foreign_key: { on_delete: :cascade, to_table: :statuses }, null: true
      t.belongs_to :target_account, foreign_key: { on_delete: :cascade, to_table: :accounts }, null: true
      t.timestamps
    end
  end
end
