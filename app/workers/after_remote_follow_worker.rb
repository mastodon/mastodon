# frozen_string_literal: true

class AfterRemoteFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  def perform(follow_id); end
end
