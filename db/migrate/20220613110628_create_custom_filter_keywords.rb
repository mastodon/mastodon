# frozen_string_literal: true

class CreateCustomFilterKeywords < ActiveRecord::Migration[6.1]
  def change
    create_table :custom_filter_keywords do |t|
      t.belongs_to :custom_filter, foreign_key: { on_delete: :cascade }, null: false
      t.text :keyword, null: false, default: ''
      t.boolean :whole_word, null: false, default: true

      t.timestamps
    end
  end
end
