# frozen_string_literal: true

class BulkImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(import_id)
    import = BulkImport.find(import_id)
    import.state_in_progress!
    BulkImportService.new.call(import)
  end
end
