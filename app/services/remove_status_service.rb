# frozen_string_literal: true

class RemoveStatusService < BaseService
  include StreamEntryRenderer

  def call(status)
    @payload      = Oj.dump(event: :delete, payload: status.id)
    @status       = status
    @account      = status.account
    @tags         = status.tags.pluck(:name).to_a
    @mentions     = status.mentions.includes(:account).to_a
    @reblogs      = status.reblogs.to_a
    @stream_entry = status.stream_entry

    remove_from_self if status.account.local?
    remove_from_followers
    remove_reblogs
    remove_from_hashtags
    remove_from_public

    @status.destroy!

    return unless @account.local?

    remove_from_mentioned(@stream_entry.reload)
    Pubsubhubbub::DistributionWorker.perform_async(@stream_entry.id)
  end

  private

  def remove_from_self
    unpush(:home, @account, @status)
  end

  def remove_from_followers
    @account.followers.local.find_each do |follower|
      unpush(:home, follower, @status)
    end
  end

  def remove_from_mentioned(stream_entry)
    salmon_xml       = stream_entry_to_xml(stream_entry)
    target_accounts  = @mentions.map(&:account).reject(&:local?).uniq(&:domain)

    NotificationWorker.push_bulk(target_accounts) do |target_account|
      [salmon_xml, stream_entry.account_id, target_account.id]
    end
  end

  def remove_reblogs
    # We delete reblogs of the status before the original status,
    # because once original status is gone, reblogs will disappear
    # without us being able to do all the fancy stuff

    @reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog)
    end
  end

  def unpush(type, receiver, status)
    if status.reblog? && !redis.zscore(FeedManager.instance.key(type, receiver.id), status.reblog_of_id).nil?
      redis.zadd(FeedManager.instance.key(type, receiver.id), status.reblog_of_id, status.reblog_of_id)
    else
      redis.zremrangebyscore(FeedManager.instance.key(type, receiver.id), status.id, status.id)
    end

    Redis.current.publish("timeline:#{receiver.id}", @payload)
  end

  def remove_from_hashtags
    @tags.each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if @status.local?
    end
  end

  def remove_from_public
    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if @status.local?
  end

  def redis
    Redis.current
  end
end
