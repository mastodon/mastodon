# frozen_string_literal: true

class UnfollowFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(follower_account_id, old_target_account_id, new_target_account_id)
    follower_account   = Account.find(follower_account_id)
    old_target_account = Account.find(old_target_account_id)
    new_target_account = Account.find(new_target_account_id)

    FollowService.new.call(follower_account, new_target_account)
    UnfollowService.new.call(follower_account, old_target_account, skip_unmerge: true)
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    true
  end
end
