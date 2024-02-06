# frozen_string_literal: true

class BulkImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(import_id)
    import = BulkImport.find(import_id)
    import.update!(state: :in_progress)
    BulkImportService.new.call(import)
  end
end
