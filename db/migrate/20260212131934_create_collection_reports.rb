# frozen_string_literal: true

class CreateCollectionReports < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_reports do |t|
      t.references :collection, null: false, foreign_key: { on_delete: :cascade }
      t.references :report, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
