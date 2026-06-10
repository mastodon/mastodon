# frozen_string_literal: true

class AddFolderToBookmarks < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :bookmarks, :folder, null: true, index: { algorithm: :concurrently }
  end
end
