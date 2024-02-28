# frozen_string_literal: true

class AddTargetStatusIdToPreviewCards < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_belongs_to :preview_cards, :target_status, null: true, index: { algorithm: :concurrently, where: 'target_status_id IS NOT NULL' }
  end
end
