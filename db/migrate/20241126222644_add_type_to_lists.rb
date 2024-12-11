# frozen_string_literal: true

class AddTypeToLists < ActiveRecord::Migration[7.2]
  def change
    add_column :lists, :type, :integer, default: 0, null: false
    add_column :lists, :description, :text, default: '', null: false
  end
end
