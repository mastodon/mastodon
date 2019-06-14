class CreateFeaturedTags < ActiveRecord::Migration[5.2]
  def change
    create_table :featured_tags do |t|
      t.references :account, foreign_key: { on_delete: :cascade }
      t.references :tag, foreign_key: { on_delete: :cascade }
      t.bigint :statuses_count, default: 0, null: false
      t.datetime :last_status_at

      t.timestamps
    end
  end
end
