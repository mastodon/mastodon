class ChangeLanguageFilterToOptOut < ActiveRecord::Migration[5.0]
  def change
    change_table :users, bulk: true do |t|
      t.remove_index :allowed_languages
      t.remove :allowed_languages

      t.column :filtered_languages, :string, array: true, default: [], null: false
      t.index :filtered_languages, using: :gin
    end
  end
end
