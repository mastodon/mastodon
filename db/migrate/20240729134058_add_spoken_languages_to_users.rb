# frozen_string_literal: true

class AddSpokenLanguagesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :spoken_languages, :string, array: true, null: false, default: []
  end
end
