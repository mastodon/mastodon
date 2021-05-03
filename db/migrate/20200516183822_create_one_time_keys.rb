class CreateOneTimeKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :one_time_keys do |t|
      t.references :device, foreign_key: { on_delete: :cascade }
      t.string :key_id, default: '', null: false, index: :unique
      t.text :key, default: '', null: false
      t.text :signature, default: '', null: false

      t.timestamps
    end
  end
end
