# frozen_string_literal: true

class FetchReplyWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_url)
    FetchRemoteStatusService.new.call(child_url)
  end
end
