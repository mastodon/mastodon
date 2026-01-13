# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', lock: :until_executed

  def perform(account_id, url, expected_digest = nil)
    @account = Account.find_by(id: account_id)
    return true if @account.nil?

    ActivityPub::SynchronizeFollowersService.new.call(@account, url, expected_digest)
  end
end
