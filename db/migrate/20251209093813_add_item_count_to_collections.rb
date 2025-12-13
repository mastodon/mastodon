# frozen_string_literal: true

class AddItemCountToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :item_count, :integer, default: 0, null: false
  end
end
