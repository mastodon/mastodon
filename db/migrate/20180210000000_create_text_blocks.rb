class CreateTextBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :text_blocks do |t|
      t.string :text, index: { unique: true }, null: false
      t.integer :severity, null: false
      t.timestamps
    end
  end
end
