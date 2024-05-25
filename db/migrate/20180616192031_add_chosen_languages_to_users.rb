# frozen_string_literal: true

class AddChosenLanguagesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :chosen_languages, :string, array: true, null: true, default: nil
  end
end
