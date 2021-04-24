class AddVisibilityToFavouriteTags < ActiveRecord::Migration[5.1]
  def change
    add_column :favourite_tags, :visibility, :integer, null: false, default: 0

    FavouriteTag.update_all(visibility: FavouriteTag.visibilities[:public])
  end
end
