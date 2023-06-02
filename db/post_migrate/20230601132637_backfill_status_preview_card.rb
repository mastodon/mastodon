# frozen_string_literal: true

class BackfillStatusPreviewCard < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class PreviewCardStatusJoin < ApplicationRecord
    self.table_name = 'preview_cards_statuses'
    self.primary_key = 'status_id'

    # This is similar to ActiveRecord::Batch::in_batches but it yield
    # primary keys instead of a relationship with `where(primary_key: …)`.
    # It's simplified to only work on the primary key and not any other column.
    # This is all to avoid an unnecessary SQL round-trip on each batch.
    def self.pluck_in_batches
      relation = all.reorder(status_id: :desc).limit(1_000)
      relation.skip_query_cache!

      batch_relation = relation

      loop do
        batch = batch_relation.pluck('DISTINCT status_id')

        break if batch.empty?

        primary_key_offset = batch.last

        yield batch

        break if batch.size < 1_000

        batch_relation = relation.where(status_id: ...primary_key_offset)
      end
    end
  end

  class Status < ApplicationRecord; end

  def up
    PreviewCardStatusJoin.pluck_in_batches do |ids|
      Status.where(id: ids)
            .update_all( # rubocop:disable Rails/SkipsModelValidations
              'preview_card_id = (SELECT preview_card_id FROM preview_cards_statuses WHERE status_id = statuses.id LIMIT 1)'
            )
    end
  end

  def down; end
end
