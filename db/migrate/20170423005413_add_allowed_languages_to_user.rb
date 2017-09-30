class AddAllowedLanguagesToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :allowed_languages, :string, array: true, default: [], null: false
    add_index :users, :allowed_languages, using: :gin
  end
end
