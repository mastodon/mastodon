class CreateCircles < ActiveRecord::Migration[5.2]
  def change
    create_table :circles do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, null: false
      t.string :title, default: '', null: false

      t.timestamps
    end
  end
end
