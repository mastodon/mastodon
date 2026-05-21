# frozen_string_literal: true

class AddURLToCollections < ActiveRecord::Migration[8.1]
  def change
    add_column :collections, :url, :string
  end
end
