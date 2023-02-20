class AddIndexFavouritesOnAccountIdAndId < ActiveRecord::Migration[5.1]
  def change
    # Used to query favourites of an account ordered by id.
    add_index :favourites, %i(account_id id)
  end
end
