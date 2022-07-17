class AddTrendableToPreviewCards < ActiveRecord::Migration[6.1]
  def change
    add_column :preview_cards, :trendable, :boolean
  end
end
