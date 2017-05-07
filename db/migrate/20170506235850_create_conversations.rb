class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations, id: false do |t|
      t.bigint :id
      t.string :uri, null: true, default: nil
      t.timestamps
    end

    add_index :conversations, :uri, unique: true
  end
end
