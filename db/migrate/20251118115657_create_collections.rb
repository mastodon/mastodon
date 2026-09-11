# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.string :uri
      t.boolean :local, null: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :sensitive, null: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :discoverable, null: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.references :tag, foreign_key: true
      t.integer :original_number_of_items

      t.timestamps
    end
  end
end
