# frozen_string_literal: true

class AddUriToCollectionItems < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_items, :uri, :string
  end
end
