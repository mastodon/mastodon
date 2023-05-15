# frozen_string_literal: true

class CreatePhraseBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :phrase_blocks do |t|
      t.text :phrase, null: false
      t.integer :filter_type, null: false, default: 0
      t.boolean :whole_word, null: false, default: true

      t.timestamps
    end
  end
end
