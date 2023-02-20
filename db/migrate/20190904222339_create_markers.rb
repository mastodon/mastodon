class CreateMarkers < ActiveRecord::Migration[5.2]
  def change
    create_table :markers do |t|
      t.references :user, foreign_key: { on_delete: :cascade, index: false }
      t.string :timeline, default: '', null: false
      t.bigint :last_read_id, default: 0, null: false
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end

    add_index :markers, %i(user_id timeline), unique: true
  end
end
