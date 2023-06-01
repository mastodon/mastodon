# frozen_string_literal: true

class DropJoinTablePreviewCardsStatuses < ActiveRecord::Migration[6.1]
  def change
    drop_join_table :preview_cards, :statuses do |t|
      t.index [:status_id, :preview_card_id]
    end
  end
end
