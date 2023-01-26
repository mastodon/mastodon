# frozen_string_literal: true

class FetchReplyWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_url, options = {})
    FetchRemoteStatusService.new.call(child_url, **options.deep_symbolize_keys)
  end
end
