class CreateRules < ActiveRecord::Migration[5.2]
  def change
    create_table :rules do |t|
      t.integer :priority, null: false, default: 0
      t.datetime :deleted_at
      t.text :text, null: false, default: ''

      t.timestamps
    end
  end
end
