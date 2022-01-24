class CreateAppeals < ActiveRecord::Migration[6.1]
  def change
    create_table :appeals do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :account_warning, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.text :text, null: false, default: ''

      t.timestamps
    end
  end
end
