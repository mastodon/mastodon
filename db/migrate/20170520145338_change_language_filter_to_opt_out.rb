# frozen_string_literal: true

class ChangeLanguageFilterToOptOut < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :allowed_languages

    change_table(:users, bulk: true) do |t|
      t.remove :allowed_languages, type: :string, array: true, default: [], null: false
      t.column :filtered_languages, :string, array: true, default: [], null: false
    end

    add_index :users, :filtered_languages, using: :gin
  end
end
