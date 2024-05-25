# frozen_string_literal: true

# NOTE: This is a deprecated worker, only kept to not break ongoing imports
# on upgrade. See `ImportWorker` for its replacement.

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
