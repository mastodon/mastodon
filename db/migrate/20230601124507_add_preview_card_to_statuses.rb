# frozen_string_literal: true

class AddPreviewCardToStatuses < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :statuses, :preview_card, null: true, index: { algorithm: :concurrently, where: 'preview_card_id IS NOT NULL' }
  end
end
