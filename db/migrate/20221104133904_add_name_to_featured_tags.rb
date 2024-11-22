# frozen_string_literal: true

class AddNameToFeaturedTags < ActiveRecord::Migration[6.1]
  def change
    add_column :featured_tags, :name, :string
  end
end
