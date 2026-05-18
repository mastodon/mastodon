# frozen_string_literal: true

class AddUniqueIndexesToCollectionsAndItems < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :collections, :uri, unique: true, where: 'uri IS NOT NULL', algorithm: :concurrently
    add_index :collection_items, :uri, unique: true, where: 'uri IS NOT NULL', algorithm: :concurrently
  end
end
