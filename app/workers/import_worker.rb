# frozen_string_literal: true

class ImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(import_id)
    import = Import.find(import_id)
    ImportService.new.call(import)
  ensure
    import&.destroy
  end
end
