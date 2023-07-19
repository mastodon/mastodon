# frozen_string_literal: true

class CreateBulkImportRows < ActiveRecord::Migration[6.1]
  def change
    create_table :bulk_import_rows do |t|
      t.references :bulk_import, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :data

      t.timestamps
    end
  end
end
