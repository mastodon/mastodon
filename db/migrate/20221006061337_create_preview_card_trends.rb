class CreatePreviewCardTrends < ActiveRecord::Migration[6.1]
  def change
    create_table :preview_card_trends do |t|
      t.references :preview_card, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.float :score, null: false, default: 0
      t.integer :rank, null: false, default: 0
      t.boolean :allowed, null: false, default: false
      t.string :language
    end
  end
end
