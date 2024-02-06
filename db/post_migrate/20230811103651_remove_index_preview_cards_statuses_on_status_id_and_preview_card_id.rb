# frozen_string_literal: true

class RemoveIndexPreviewCardsStatusesOnStatusIdAndPreviewCardId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :preview_cards_statuses, column: [:status_id, :preview_card_id], name: :index_preview_cards_statuses_on_status_id_and_preview_card_id
  end
end
