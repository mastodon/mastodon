# frozen_string_literal: true

class FollowService < BaseService
  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String] uri User URI to follow in the form of username@domain
  def call(source_account, uri)
    target_account = follow_remote_account_service.call(uri)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id || target_account.suspended?

    follow = source_account.follow!(target_account)

    if target_account.local?
      NotifyService.new.call(target_account, follow)
    else
      subscribe_service.call(target_account)
      NotificationWorker.perform_async(follow.stream_entry.id, target_account.id)
    end

    merge_into_timeline(target_account, source_account)

    Pubsubhubbub::DistributionWorker.perform_async(follow.stream_entry.id)

    follow
  end

  private

  def merge_into_timeline(from_account, into_account)
    timeline_key = FeedManager.instance.key(:home, into_account.id)

    from_account.statuses.find_each do |status|
      redis.zadd(timeline_key, status.id, status.id)
    end

    FeedManager.instance.trim(:home, into_account.id)
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
