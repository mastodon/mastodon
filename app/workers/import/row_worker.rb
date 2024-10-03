# frozen_string_literal: true

class Import::RowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 6, dead: false

  sidekiq_retries_exhausted do |msg, _exception|
    ActiveRecord::Base.connection_pool.with_connection do
      # Increment the total number of processed items, and bump the state of the import if needed
      bulk_import_id = BulkImportRow.where(id: msg['args'][0]).pick(:bulk_import_id)
      BulkImport.progress!(bulk_import_id) unless bulk_import_id.nil?
    end
  end

  def perform(row_id)
    row = BulkImportRow.eager_load(bulk_import: :account).find_by(id: row_id)
    return true if row.nil?

    imported = BulkImportRowService.new.call(row)

    mark_as_processed!(row, imported)
  end

  private

  def mark_as_processed!(row, imported)
    bulk_import_id = row.bulk_import_id
    row.destroy! if imported

    BulkImport.progress!(bulk_import_id, imported: imported)
  end
end
