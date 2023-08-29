# frozen_string_literal: true

class Importer::PublicStatusesIndexImporter < Importer::BaseImporter
  def import!
    scope.select(:id).find_in_batches(batch_size: @batch_size) do |batch|
      in_work_unit(batch.pluck(:id)) do |status_ids|
        bulk = ActiveRecord::Base.connection_pool.with_connection do
          Chewy::Index::Import::BulkBuilder.new(index, to_index: Status.includes(:media_attachments, :preloadable_poll, :preview_cards).where(id: status_ids)).bulk_body
        end

        indexed = bulk.count { |entry| entry[:index] }
        deleted = bulk.count { |entry| entry[:delete] }

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

  def scope
    Status.indexable
  end
end
