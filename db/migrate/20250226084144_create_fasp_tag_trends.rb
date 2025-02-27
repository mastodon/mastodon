# frozen_string_literal: true

class CreateFaspTagTrends < ActiveRecord::Migration[8.0]
  def change
    create_table :fasp_tag_trends do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :fasp_provider, null: false, foreign_key: true
      t.integer :rank, null: false
      t.string :language, null: false
      t.boolean :allowed, null: false, default: false

      t.timestamps
    end
  end
end
