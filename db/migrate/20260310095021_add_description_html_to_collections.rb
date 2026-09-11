# frozen_string_literal: true

class AddDescriptionHtmlToCollections < ActiveRecord::Migration[8.1]
  def change
    add_column :collections, :description_html, :text

    reversible do |direction|
      direction.up { change_column :collections, :description, :text, null: true }

      direction.down { change_column :collections, :description, :text, null: false }
    end
  end
end
