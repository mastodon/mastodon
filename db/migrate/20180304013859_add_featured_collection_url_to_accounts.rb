class AddFeaturedCollectionUrlToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :featured_collection_url, :string
  end
end
