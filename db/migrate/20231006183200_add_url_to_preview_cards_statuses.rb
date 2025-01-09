# frozen_string_literal: true

class AddURLToPreviewCardsStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :preview_cards_statuses, :url, :string
  end
end
