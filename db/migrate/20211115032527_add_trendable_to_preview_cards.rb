# frozen_string_literal: true

class AddTrendableToPreviewCards < ActiveRecord::Migration[6.1]
  def change
    add_column :preview_cards, :trendable, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
