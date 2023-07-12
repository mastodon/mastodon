# frozen_string_literal: true

class AddBlurhashToPreviewCards < ActiveRecord::Migration[5.2]
  def change
    add_column :preview_cards, :blurhash, :string
  end
end
