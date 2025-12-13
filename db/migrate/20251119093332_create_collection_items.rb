# frozen_string_literal: true

class CreateCollectionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_items do |t|
      t.references :collection, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, foreign_key: true
      t.integer :position, null: false, default: 1
      t.string :object_uri, index: { unique: true, where: 'activity_uri IS NOT NULL' }
      t.string :approval_uri, index: { unique: true, where: 'approval_uri IS NOT NULL' }
      t.string :activity_uri
      t.datetime :approval_last_verified_at
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
