# frozen_string_literal: true

class RemoveUriFromConversations < ActiveRecord::Migration[5.2]
  def up
    safety_assured { remove_column :conversations, :uri, :string }
  end

  def down
    add_column :conversations, :uri, :string
    add_index :conversations, :uri, unique: true
  end
end
