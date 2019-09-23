# frozen_string_literal: true

class AfterRemoteFollowRequestWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  def perform(follow_request_id); end
end
