# frozen_string_literal: true

class AddPublishedAtToPreviewCards < ActiveRecord::Migration[7.0]
  def change
    add_column :preview_cards, :published_at, :datetime
  end
end
