# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations, id: :bigserial do |t|
      t.string :uri, null: true, default: nil
      t.timestamps
    end

    add_index :conversations, :uri, unique: true
  end
end
