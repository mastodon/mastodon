# frozen_string_literal: true

class CreateSessionActivations < ActiveRecord::Migration[5.1]
  def change
    create_table :session_activations do |t|
      t.integer :user_id,   null: false
      t.string :session_id, null: false

      t.timestamps
    end

    add_index :session_activations, :user_id
    add_index :session_activations, :session_id, unique: true
  end
end
