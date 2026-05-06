# frozen_string_literal: true

class AddLanguageToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :language, :string
  end
end
