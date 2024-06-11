# frozen_string_literal: true

class CreateBulkImports < ActiveRecord::Migration[6.1]
  def change
    create_table :bulk_imports do |t|
      t.integer :type, null: false
      t.integer :state, null: false
      t.integer :total_items, null: false, default: 0
      t.integer :imported_items, null: false, default: 0
      t.integer :processed_items, null: false, default: 0
      t.datetime :finished_at
      t.boolean :overwrite, null: false, default: false
      t.boolean :likely_mismatched, null: false, default: false
      t.string :original_filename, null: false, default: ''
      t.references :account, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :bulk_imports, [:id], name: :index_bulk_imports_unconfirmed, where: 'state = 0'
  end
end
