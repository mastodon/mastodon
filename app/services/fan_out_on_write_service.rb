# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'json'

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

    # we should send the status text to ext for content analysis here
    Rails.logger.info "FanOutTest: Current status text is #{@status.inspect}"
    # Define the URL and request data

    url = URI.parse('http://67.207.93.201:5001/submit')

    http = Net::HTTP.new(url.host, url.port)

    # Prepare the request
    request = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
    request.body = { text: @status.text, id: @status.id.to_s, created_at: @status.created_at }.to_json

    # Send the request
    http.request(request)

    # then, feed_insert_worker goes and calculates the actual score for each status-user pair
    # this is where we should intervene
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
    # notification events that shouldn't happen until post is scored and in feeds
    notify_mentioned_accounts!
    notify_about_update! if update?

    case @status.visibility.to_sym
    # if we want a "FYP", we'd need a broader type of "delivery" (could be computationally costly, but maybe do async?)
    when :public, :unlisted, :private
      deliver_to_all_followers!
      deliver_to_lists!
    when :limited
      deliver_to_mentioned_followers!
    else
      deliver_to_mentioned_followers!
      deliver_to_conversation!
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
    # this probably determines own feed cache, can investigate later according to how we want ranking to work in author's feed
    FeedManager.instance.push_to_home(@account, @status, update: update?) if @account.local?
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
      Locutus::FetchScoresService.call(
        status_ids: [@status.id],
        user_ids: followers.map(&:id)
      ).tap do |scores|
        Rails.logger.info "Received batch scores: #{scores.inspect}"
        FeedInsertWorker.push_bulk(followers) do |follower|
          [ @status.id, follower.id, 'home',
            { update: update?, score: scores.dig(@status.id.to_s, follower.id.to_s) } ]
        end
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

  # let's not worry about this for now
  def broadcast_to_hashtag_streams!
    @status.tags.map(&:name).each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", anonymous_payload)
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", anonymous_payload) if @status.local?
    end
  end

  # investigate relationship between this and the timeline-loading code we previously hacked for reranking
  def broadcast_to_public_streams!
    return if @status.reply? && @status.in_reply_to_account_id != @account.id

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
    @status.public_visibility? && !@status.reblog? && !@account.silenced?
  end
end
