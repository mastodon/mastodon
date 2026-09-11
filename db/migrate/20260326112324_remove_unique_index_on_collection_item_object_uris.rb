# frozen_string_literal: true

class RemoveUniqueIndexOnCollectionItemObjectUris < ActiveRecord::Migration[8.1]
  def change
    remove_index :collection_items, :object_uri, unique: true, where: '(activity_uri IS NOT NULL)'
  end
end
