# frozen_string_literal: true

class UnfollowFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(follower_account_id, old_target_account_id, new_target_account_id, bypass_locked = false)
    follower_account   = Account.find(follower_account_id)
    old_target_account = Account.find(old_target_account_id)
    new_target_account = Account.find(new_target_account_id)

    follow  = follower_account.active_relationships.find_by(target_account: old_target_account)
    reblogs = follow&.show_reblogs?
    notify  = follow&.notify?

    FollowService.new.call(follower_account, new_target_account, reblogs: reblogs, notify: notify, bypass_locked: bypass_locked)
    UnfollowService.new.call(follower_account, old_target_account, skip_unmerge: true)
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    true
  end
end
