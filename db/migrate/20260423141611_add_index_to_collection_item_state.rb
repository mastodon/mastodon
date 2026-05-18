# frozen_string_literal: true

class AddIndexToCollectionItemState < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :collection_items, :state, where: 'state IN (2, 3)', algorithm: :concurrently
  end
end
