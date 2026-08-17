# frozen_string_literal: true

class AddCollectionsURLToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :collections_url, :string
  end
end
