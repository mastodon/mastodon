class CreateFavouriteTags < ActiveRecord::Migration[5.1]
  def change
    create_table :favourite_tags do |t|
      t.integer :account_id, null: false
      t.integer :tag_id, null: false
      t.index [:account_id, :tag_id], unique: true
      t.foreign_key :accounts, on_delete: :cascade
      t.foreign_key :tags, on_delete: :cascade
      t.timestamps
    end
  end
end
