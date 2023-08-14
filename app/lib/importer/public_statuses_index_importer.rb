# frozen_string_literal: true

class Importer::PublicStatusesIndexImporter < Importer::BaseImporter
  def import!
    indexable_statuses_scope.find_in_batches(batch_size: @batch_size) do |batch|
      in_work_unit(batch.map(&:status_id)) do |status_ids|
        bulk = ActiveRecord::Base.connection_pool.with_connection do
          Chewy::Index::Import::BulkBuilder.new(index, to_index: Status.includes(:media_attachments, :preloadable_poll).where(id: status_ids)).bulk_body
        end

        indexed = 0
        deleted = 0

        bulk.map! do |entry|
          if entry[:index]
            indexed += 1
          else
            deleted += 1
          end
          entry
        end

        Chewy::Index::Import::BulkRequest.new(index).perform(bulk)

        [indexed, deleted]
      end
    end

    wait!
  end

  private

  def index
    PublicStatusesIndex
  end

  def indexable_statuses_scope
    Status.indexable.select('"statuses"."id", COALESCE("statuses"."reblog_of_id", "statuses"."id") AS status_id')
  end
end
