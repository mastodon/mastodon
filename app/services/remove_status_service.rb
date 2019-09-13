# frozen_string_literal: true

class RemoveStatusService < BaseService
  include Redisable
  include Payloadable

  # Delete a status
  # @param   [Status] status
  # @param   [Hash] options
  # @option  [Boolean] :redraft
  # @option  [Boolean] :immediate
  # @option [Boolean] :original_removed
  def call(status, **options)
    @payload  = Oj.dump(event: :delete, payload: status.id.to_s)
    @status   = status
    @account  = status.account
    @tags     = status.tags.pluck(:name).to_a
    @mentions = status.active_mentions.includes(:account).to_a
    @reblogs  = status.reblogs.includes(:account).to_a
    @options  = options

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        remove_from_self if status.account.local?
        remove_from_followers
        remove_from_lists
        remove_from_affected
        remove_reblogs
        remove_from_hashtags
        remove_from_public
        remove_from_media if status.media_attachments.any?
        remove_from_direct if status.direct_visibility?
        remove_from_spam_check
        remove_media

        @status.destroy! if @options[:immediate] || !@status.reported?
      else
        raise Mastodon::RaceConditionError
      end
    end

    # There is no reason to send out Undo activities when the
    # cause is that the original object has been removed, since
    # original object being removed implicitly removes reblogs
    # of it. The Delete activity of the original is forwarded
    # separately.
    return if !@account.local? || @options[:original_removed]

    remove_from_remote_followers
    remove_from_remote_affected
  end

  private

  def remove_from_self
    FeedManager.instance.unpush_from_home(@account, @status)
    FeedManager.instance.unpush_from_direct(@account, @status) if @status.direct_visibility?
  end

  def remove_from_followers
    @account.followers_for_local_distribution.reorder(nil).find_each do |follower|
      FeedManager.instance.unpush_from_home(follower, @status)
    end
  end

  def remove_from_lists
    @account.lists_for_local_distribution.select(:id, :account_id).reorder(nil).find_each do |list|
      FeedManager.instance.unpush_from_list(list, @status)
    end
  end

  def remove_from_affected
    @mentions.map(&:account).select(&:local?).each do |account|
      redis.publish("timeline:#{account.id}", @payload)
    end
  end

  def remove_from_remote_affected
    # People who got mentioned in the status, or who
    # reblogged it from someone else might not follow
    # the author and wouldn't normally receive the
    # delete notification - so here, we explicitly
    # send it to them

    target_accounts = (@mentions.map(&:account).reject(&:local?) + @reblogs.map(&:account).reject(&:local?))
    target_accounts << @status.reblog.account if @status.reblog? && !@status.reblog.account.local?
    target_accounts.uniq!(&:id)

    # ActivityPub
    ActivityPub::DeliveryWorker.push_bulk(target_accounts.select(&:activitypub?).uniq(&:preferred_inbox_url)) do |target_account|
      [signed_activity_json, @account.id, target_account.preferred_inbox_url]
    end
  end

  def remove_from_remote_followers
    # ActivityPub
    ActivityPub::DeliveryWorker.push_bulk(@account.followers.inboxes) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end

    relay! if relayable?
  end

  def relayable?
    @status.public_visibility?
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@status, @status.reblog? ? ActivityPub::UndoAnnounceSerializer : ActivityPub::DeleteSerializer, signer: @account))
  end

  def remove_reblogs
    # We delete reblogs of the status before the original status,
    # because once original status is gone, reblogs will disappear
    # without us being able to do all the fancy stuff

    @reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog, original_removed: true)
    end
  end

  def remove_from_hashtags
    @account.featured_tags.where(tag_id: @status.tags.pluck(:id)).each do |featured_tag|
      featured_tag.decrement(@status.id)
    end

    return unless @status.public_visibility?

    @tags.each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", @payload)
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", @payload) if @status.local?
    end
  end

  def remove_from_public
    return unless @status.public_visibility?

    redis.publish('timeline:public', @payload)
    redis.publish('timeline:public:local', @payload) if @status.local?
  end

  def remove_from_media
    return unless @status.public_visibility?

    redis.publish('timeline:public:media', @payload)
    redis.publish('timeline:public:local:media', @payload) if @status.local?
  end

  def remove_from_direct
    @mentions.each do |mention|
      FeedManager.instance.unpush_from_direct(mention.account, @status) if mention.account.local?
    end
  end

  def remove_media
    return if @options[:redraft] || (!@options[:immediate] && @status.reported?)

    @status.media_attachments.destroy_all
  end

  def remove_from_spam_check
    redis.zremrangebyscore("spam_check:#{@status.account_id}", @status.id, @status.id)
  end

  def lock_options
    { redis: Redis.current, key: "distribute:#{@status.id}" }
  end
end
