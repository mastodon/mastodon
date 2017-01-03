# frozen_string_literal: true

class FollowService < BaseService
  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String] uri User URI to follow in the form of username@domain
  def call(source_account, uri)
    target_account = follow_remote_account_service.call(uri)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id || target_account.suspended?
    raise Mastodon::NotPermitted       if target_account.blocking?(source_account)

    if target_account.locked?
      request_follow(source_account, target_account)
    else
      direct_follow(source_account, target_account)
    end
  end

  private

  def request_follow(source_account, target_account)
    return unless target_account.local?

    follow_request = FollowRequest.create!(account: source_account, target_account: target_account)
    NotifyService.new.call(target_account, follow_request)

    follow_request
  end

  def direct_follow(source_account, target_account)
    follow = source_account.follow!(target_account)

    if target_account.local?
      NotifyService.new.call(target_account, follow)
    else
      subscribe_service.call(target_account)
      NotificationWorker.perform_async(follow.stream_entry.id, target_account.id)
    end

    FeedManager.instance.merge_into_timeline(target_account, source_account)
    Pubsubhubbub::DistributionWorker.perform_async(follow.stream_entry.id)

    follow
  end

  def redis
    Redis.current
  end

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def subscribe_service
    @subscribe_service ||= SubscribeService.new
  end
end
