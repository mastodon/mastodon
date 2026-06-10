# frozen_string_literal: true

class ValidateForeignKeyOnBookmarksFolders < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :bookmarks, :bookmark_folders, column: :folder_id
  end
end
