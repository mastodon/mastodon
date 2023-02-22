# frozen_string_literal: true

class AddFeaturedCollectionURLToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :featured_collection_url, :string
  end
end
