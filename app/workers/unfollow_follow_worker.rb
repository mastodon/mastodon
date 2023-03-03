# frozen_string_literal: true

class UnfollowFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(follower_account_id, old_target_account_id, new_target_account_id, bypass_locked = false)
    follower_account   = Account.find(follower_account_id)
    old_target_account = Account.find(old_target_account_id)
    new_target_account = Account.find(new_target_account_id)

    FollowMigrationService.new.call(follower_account, new_target_account, old_target_account, bypass_locked: bypass_locked)
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    true
  end
end
