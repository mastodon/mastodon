class CreateLists < ActiveRecord::Migration[5.1]
  def change
    create_table :lists do |t|
      t.references :account, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, default: ''

      t.timestamps
    end
  end
end
