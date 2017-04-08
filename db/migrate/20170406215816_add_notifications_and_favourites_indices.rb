class AddNotificationsAndFavouritesIndices < ActiveRecord::Migration[5.0]
  def change
    add_index :notifications, [:activity_id, :activity_type]
    add_index :accounts, :url
    add_index :favourites, :status_id
  end
end
