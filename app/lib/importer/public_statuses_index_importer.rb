# frozen_string_literal: true

class Importer::PublicStatusesIndexImporter < Importer::BaseImporter
  def import!
    scope.select(:id).find_in_batches(batch_size: @batch_size) do |batch|
      in_work_unit(batch.pluck(:id)) do |status_ids|
        bulk = ActiveRecord::Base.connection_pool.with_connection do
          build_bulk_body(index.adapter.default_scope.where(id: status_ids))
        end

        indexed = bulk.size
        deleted = 0

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
    Status.indexable.reorder(nil)
  end
end
