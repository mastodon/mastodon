# frozen_string_literal: true

class FetchReplyWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 3

  sidekiq_retry_in do |count|
    15 + 10 * (count**4) + rand(10 * (count**4))
  end

  def perform(child_url)
    FetchRemoteStatusService.new.call(child_url)
  end
end
