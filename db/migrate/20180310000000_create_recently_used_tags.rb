class CreateRecentlyUsedTags < ActiveRecord::Migration[5.1]
  def change
    create_table :recently_used_tags do |t|
      t.integer :index, null: false
      t.belongs_to :account, foreign_key: { on_delete: :cascade, on_update: :cascade }, index: false, null: false
      t.references :tag, foreign_key: { on_delete: :cascade, on_update: :cascade, primary_key: :name }, null: false, type: :string
      t.index [:account_id, :tag_id], unique: true
      t.index [:account_id, :index]
    end
  end
end
