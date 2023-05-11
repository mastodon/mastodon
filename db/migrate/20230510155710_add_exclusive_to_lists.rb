# frozen_string_literal: true

class AddExclusiveToLists < ActiveRecord::Migration[6.1]
  def change
    add_column :lists, :exclusive, :boolean, null: false, default: false
  end
end
