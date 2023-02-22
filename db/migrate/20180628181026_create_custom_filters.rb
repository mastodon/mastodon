# frozen_string_literal: true

class CreateCustomFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_filters do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.datetime :expires_at
      t.text :phrase, null: false, default: ''
      t.string :context, array: true, null: false, default: []
      t.boolean :irreversible, null: false, default: false

      t.timestamps
    end
  end
end
