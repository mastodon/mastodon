class CreateStatusStats < ActiveRecord::Migration[5.2]
  def change
    create_table :status_stats do |t|
      t.belongs_to :status, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.bigint :replies_count, null: false, default: 0
      t.bigint :reblogs_count, null: false, default: 0
      t.bigint :favourites_count, null: false, default: 0

      t.timestamps
    end
  end
end
