# frozen_string_literal: true

class AfterRemoteFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  def perform(follow_id)
    follow          = Follow.find(follow_id)
    updated_account = FetchRemoteAccountService.new.call(follow.target_account.remote_url)

    return if updated_account.nil? || !updated_account.locked?

    follow.destroy
    FollowService.new.call(follow.account, updated_account.acct)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
