# frozen_string_literal: true

class CreateRuleTranslations < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_translations do |t|
      t.text :text, null: false, default: ''
      t.text :hint, null: false, default: ''
      t.string :language, null: false
      t.references :rule, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.timestamps
    end

    add_index :rule_translations, [:rule_id, :language], unique: true
  end
end
