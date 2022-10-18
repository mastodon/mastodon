class AddFeaturedTagsURLToAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :featured_tags_collection_url, :string
  end
end
