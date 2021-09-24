# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', lock: :until_executed

  def perform(account_id, url)
    ActivityPub::SynchronizeFollowersService.new.call(Account.find(account_id), url)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
