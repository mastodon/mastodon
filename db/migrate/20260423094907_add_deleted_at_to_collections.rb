# frozen_string_literal: true

class AddDeletedAtToCollections < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :collections, :deleted_at, :datetime
    add_index :collections, :deleted_at, algorithm: :concurrently
  end
end
