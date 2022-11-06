# frozen_string_literal: true

class FanOutOnWriteService < BaseService
  include Redisable

  # Push a status into home and mentions feeds
  # @param [Status] status
  # @param [Hash] options
  # @option options [Boolean] update
  # @option options [Array<Integer>] silenced_account_ids
  def call(status, options = {})
    @status    = status
    @account   = status.account
    @options   = options

    check_race_condition!
    warm_payload_cache!

    fan_out_to_local_recipients!
    fan_out_to_public_recipients! if broadcastable?
    fan_out_to_public_streams! if broadcastable?
  end

  private

  def check_race_condition!
    # I don't know why but at some point we had an issue where
    # this service was being executed with status objects
    # that had a null visibility - which should not be possible
    # since the column in the database is not nullable.
    #
    # This check re-queues the service to be run at a later time
    # with the full object, if something like it occurs

    raise Mastodon::RaceConditionError if @status.visibility.nil?
  end

  def fan_out_to_local_recipients!
    deliver_to_self!
    notify_mentioned_accounts!
    notify_about_update! if update?

    case @status.visibility.to_sym
    when :public, :unlisted, :private
      deliver_to_all_followers!
      deliver_to_lists!
    when :limited
      deliver_to_mentioned_followers!
    else
      deliver_to_mentioned_followers!
      deliver_to_conversation!
      deliver_to_direct_timelines!
    end
  end

  def fan_out_to_public_recipients!
    deliver_to_hashtag_followers!
  end

  def fan_out_to_public_streams!
    broadcast_to_hashtag_streams!
    broadcast_to_public_streams!
  end

  def deliver_to_self!
    FeedManager.instance.push_to_home(@account, @status, update: update?) if @account.local?
    FeedManager.instance.push_to_direct(@account, @status, update: update?) if @account.local? && @status.direct_visibility?
  end

  def notify_mentioned_accounts!
    @status.active_mentions.where.not(id: @options[:silenced_account_ids] || []).joins(:account).merge(Account.local).select(:id, :account_id).reorder(nil).find_in_batches do |mentions|
      LocalNotificationWorker.push_bulk(mentions) do |mention|
        [mention.account_id, mention.id, 'Mention', 'mention']
      end
    end
  end

  def notify_about_update!
    @status.reblogged_by_accounts.merge(Account.local).select(:id).reorder(nil).find_in_batches do |accounts|
      LocalNotificationWorker.push_bulk(accounts) do |account|
        [account.id, @status.id, 'Status', 'update']
      end
    end
  end

  def deliver_to_all_followers!
    @account.followers_for_local_distribution.select(:id).reorder(nil).find_in_batches do |followers|
      FeedInsertWorker.push_bulk(followers) do |follower|
        [@status.id, follower.id, 'home', { 'update' => update? }]
      end
    end
  end

  def deliver_to_hashtag_followers!
    TagFollow.where(tag_id: @status.tags.map(&:id)).select(:id, :account_id).reorder(nil).find_in_batches do |follows|
      FeedInsertWorker.push_bulk(follows) do |follow|
        [@status.id, follow.account_id, 'tags', { 'update' => update? }]
      end
    end
  end

  def deliver_to_lists!
    @account.lists_for_local_distribution.select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [@status.id, list.id, 'list', { 'update' => update? }]
      end
    end
  end

  def deliver_to_mentioned_followers!
    @status.mentions.joins(:account).merge(@account.followers_for_local_distribution).select(:id, :account_id).reorder(nil).find_in_batches do |mentions|
      FeedInsertWorker.push_bulk(mentions) do |mention|
        [@status.id, mention.account_id, 'home', { 'update' => update? }]
      end
    end
  end

  def deliver_to_direct_timelines!
    FeedInsertWorker.push_bulk(@status.mentions.includes(:account).map(&:account).select { |mentioned_account| mentioned_account.local? }) do |account|
      [@status.id, account.id, 'direct', { 'update' => update? }]
    end
  end

  def broadcast_to_hashtag_streams!
    @status.tags.map(&:name).each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", anonymous_payload)
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", anonymous_payload) if @status.local?
    end
  end

  def broadcast_to_public_streams!
    return if @status.reply? && @status.in_reply_to_account_id != @account.id && !Setting.show_replies_in_public_timelines

    redis.publish('timeline:public', anonymous_payload)
    redis.publish(@status.local? ? 'timeline:public:local' : 'timeline:public:remote', anonymous_payload)

    if @status.with_media?
      redis.publish('timeline:public:media', anonymous_payload)
      redis.publish(@status.local? ? 'timeline:public:local:media' : 'timeline:public:remote:media', anonymous_payload)
    end
  end

  def deliver_to_conversation!
    AccountConversation.add_status(@account, @status) unless update?
  end

  def warm_payload_cache!
    Rails.cache.write("fan-out/#{@status.id}", rendered_status)
  end

  def anonymous_payload
    @anonymous_payload ||= Oj.dump(
      event: update? ? :'status.update' : :update,
      payload: rendered_status
    )
  end

  def rendered_status
    @rendered_status ||= InlineRenderer.render(@status, nil, :status)
  end

  def update?
    @options[:update]
  end

  def broadcastable?
    @status.public_visibility? && !@account.silenced? && (!@status.reblog? || Setting.show_reblogs_in_public_timelines)
  end
end
