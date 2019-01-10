# frozen_string_literal: true

class RefollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(target_account_id)
    target_account = Account.find(target_account_id)
    return unless target_account.protocol == :activitypub

    target_account.followers.where(domain: nil).reorder(nil).find_each do |follower|
      # Locally unfollow remote account
      follower.unfollow!(target_account)

      # Schedule re-follow
      begin
        FollowService.new.call(follower, target_account)
      rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound, Mastodon::UnexpectedResponseError, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end
end
