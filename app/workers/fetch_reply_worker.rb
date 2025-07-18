# frozen_string_literal: true

class FetchReplyWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_url, options = {})
    batch = WorkerBatch.new(options.delete('batch_id')) if options['batch_id']
    FetchRemoteStatusService.new.call(child_url, **options.symbolize_keys)
  ensure
    batch&.remove_job(jid)
  end
end
