# frozen_string_literal: true

class CreatePreviewCards < ActiveRecord::Migration[5.0]
  def change
    create_table :preview_cards do |t|
      t.integer :status_id
      t.string :url, null: false, default: ''

      # OpenGraph
      t.string :title, null: true
      t.string :description, null: true
      t.attachment :image

      t.timestamps
    end

    add_index :preview_cards, :status_id, unique: true
  end
end
