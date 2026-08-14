# frozen_string_literal: true

class RenameIndexAccountsOnUriToOld < ActiveRecord::Migration[8.1]
  def change
    rename_index :accounts, :index_accounts_on_uri, :old_index_accounts_on_uri
  end
end
