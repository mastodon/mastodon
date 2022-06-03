# frozen_string_literal: true

class RemoveFilteredLanguagesFromUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :users, :filtered_languages, :string, array: true, default: [], null: false
    end
  end
end
