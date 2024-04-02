# frozen_string_literal: true

class Importer::TagsIndexImporter < Importer::BaseImporter
  def import!
    index.adapter.default_scope.find_in_batches(batch_size: @batch_size) do |tmp|
      in_work_unit(tmp) do |tags|
        bulk = build_bulk_body(tags)

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
    TagsIndex
  end
end
