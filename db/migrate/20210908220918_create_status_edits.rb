class CreateStatusEdits < ActiveRecord::Migration[6.1]
  def change
    create_table :status_edits do |t|
      t.belongs_to :status, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :account, null: true, foreign_key: { on_delete: :nullify }
      t.text :text, null: false, default: ''
      t.text :spoiler_text, null: false, default: ''
      t.boolean :media_attachments_changed, null: false, default: false

      t.timestamps
    end
  end
end
