# frozen_string_literal: true

class CreateTagTrends < ActiveRecord::Migration[7.2]
  def change
    create_table :tag_trends do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.float :score, null: false, default: 0
      t.integer :rank, null: false, default: 0
      t.boolean :allowed, null: false, default: false
      t.string :language, null: false, default: ''
    end

    add_index :tag_trends, [:tag_id, :language], unique: true
  end
end
