# frozen_string_literal: true

class CreateBookmarkFolders < ActiveRecord::Migration[8.1]
  def change
    create_table :bookmark_folders do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, default: ''

      t.timestamps
    end
  end
end
