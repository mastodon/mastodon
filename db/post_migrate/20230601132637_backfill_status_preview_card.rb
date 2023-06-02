# frozen_string_literal: true

class BackfillStatusPreviewCard < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class PreviewCardStatusJoin < ApplicationRecord
    self.table_name = 'preview_cards_statuses'
    self.primary_key = 'status_id'
  end

  class Status < ApplicationRecord; end

  def up
    PreviewCardStatusJoin.in_batches(order: :desc) do |preview_card_status_join|
      Status.where(id: preview_card_status_join.ids)
            .update_all( # rubocop:disable Rails/SkipsModelValidations
              'preview_card_id = (SELECT preview_card_id FROM preview_cards_statuses WHERE status_id = statuses.id LIMIT 1)'
            )
    end
  end

  def down; end
end
