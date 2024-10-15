# frozen_string_literal: true

class AddEmojiToFavourites < ActiveRecord::Migration[7.0]
  def change
    add_column :favourites, :emoji, :text
  end
end
