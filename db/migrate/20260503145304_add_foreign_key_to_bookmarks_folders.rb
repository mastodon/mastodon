# frozen_string_literal: true

class AddForeignKeyToBookmarksFolders < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :bookmarks, :bookmark_folders, column: :folder_id, on_delete: :nullify, validate: false
  end
end
