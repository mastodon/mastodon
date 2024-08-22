# frozen_string_literal: true

class AddHighlightedToTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tags, :highlighted, :boolean, null: false, default: false
  end
end
