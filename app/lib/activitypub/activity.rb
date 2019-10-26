# frozen_string_literal: true

class ActivityPub::Activity
  include JsonLdHelper
  include Redisable

  SUPPORTED_TYPES = %w(Note Question).freeze
  CONVERTED_TYPES = %w(Image Audio Video Article Page).freeze

  def initialize(json, account, **options)
    @json    = json
    @account = account
    @object  = @json['object']
    @options = options
  end

  def perform
    raise NotImplementedError
  end

  class << self
    def factory(json, account, **options)
      @json = json
      klass&.new(json, account, options)
    end

    private

    def klass
      case @json['type']
      when 'Create'
        ActivityPub::Activity::Create
      when 'Announce'
        ActivityPub::Activity::Announce
      when 'Delete'
        ActivityPub::Activity::Delete
      when 'Follow'
        ActivityPub::Activity::Follow
      when 'Like'
        ActivityPub::Activity::Like
      when 'Block'
        ActivityPub::Activity::Block
      when 'Update'
        ActivityPub::Activity::Update
      when 'Undo'
        ActivityPub::Activity::Undo
      when 'Accept'
        ActivityPub::Activity::Accept
      when 'Reject'
        ActivityPub::Activity::Reject
      when 'Flag'
        ActivityPub::Activity::Flag
      when 'Add'
        ActivityPub::Activity::Add
      when 'Remove'
        ActivityPub::Activity::Remove
      when 'Move'
        ActivityPub::Activity::Move
      end
    end
  end

  protected

  def status_from_uri(uri)
    ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
  end

  def account_from_uri(uri)
    ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
  end

  def object_uri
    @object_uri ||= value_or_id(@object)
  end

  def unsupported_object_type?
    @object.is_a?(String) || !(supported_object_type? || converted_object_type?)
  end

  def supported_object_type?
    equals_or_includes_any?(@object['type'], SUPPORTED_TYPES)
  end

  def converted_object_type?
    equals_or_includes_any?(@object['type'], CONVERTED_TYPES)
  end

  def distribute(status)
    crawl_links(status)

    notify_about_reblog(status) if reblog_of_local_account?(status)
    notify_about_mentions(status)

    # Only continue if the status is supposed to have arrived in real-time.
    # Note that if @options[:override_timestamps] isn't set, the status
    # may have a lower snowflake id than other existing statuses, potentially
    # "hiding" it from paginated API calls
    return unless @options[:override_timestamps] || status.within_realtime_window?

    distribute_to_followers(status)
  end

  def reblog_of_local_account?(status)
    status.reblog? && status.reblog.account.local?
  end

  def notify_about_reblog(status)
    NotifyService.new.call(status.reblog.account, status)
  end

  def notify_about_mentions(status)
    status.active_mentions.includes(:account).each do |mention|
      next unless mention.account.local? && audience_includes?(mention.account)
      NotifyService.new.call(mention.account, mention)
    end
  end

  def crawl_links(status)
    return if status.spoiler_text?

    # Spread out crawling randomly to avoid DDoSing the link
    LinkCrawlWorker.perform_in(rand(1..59).seconds, status.id)
  end

  def distribute_to_followers(status)
    ::DistributionWorker.perform_async(status.id)
  end

  def delete_arrived_first?(uri)
    redis.exists("delete_upon_arrival:#{@account.id}:#{uri}")
  end

  def delete_later!(uri)
    redis.setex("delete_upon_arrival:#{@account.id}:#{uri}", 6.hours.seconds, uri)
  end

  def status_from_object
    # If the status is already known, return it
    status = status_from_uri(object_uri)

    return status unless status.nil?

    # If the boosted toot is embedded and it is a self-boost, handle it like a Create
    unless unsupported_object_type?
      actor_id = value_or_id(first_of_value(@object['attributedTo']))

      if actor_id == @account.uri
        return ActivityPub::Activity.factory({ 'type' => 'Create', 'actor' => actor_id, 'object' => @object }, @account).perform
      end
    end

    fetch_remote_original_status
  end

  def follow_request_from_object
    @follow_request ||= FollowRequest.find_by(target_account: @account, uri: object_uri) unless object_uri.nil?
  end

  def follow_from_object
    @follow ||= Follow.find_by(target_account: @account, uri: object_uri) unless object_uri.nil?
  end

  def fetch_remote_original_status
    if object_uri.start_with?('http')
      return if ActivityPub::TagManager.instance.local_uri?(object_uri)
      ActivityPub::FetchRemoteStatusService.new.call(object_uri, id: true, on_behalf_of: @account.followers.local.first)
    elsif @object['url'].present?
      ::FetchRemoteStatusService.new.call(@object['url'])
    end
  end

  def lock_or_return(key, expire_after = 7.days.seconds)
    yield if redis.set(key, true, nx: true, ex: expire_after)
  ensure
    redis.del(key)
  end

  def fetch?
    !@options[:delivery]
  end

  def followed_by_local_accounts?
    @account.passive_relationships.exists?
  end

  def requested_through_relay?
    @options[:relayed_through_account] && Relay.find_by(inbox_url: @options[:relayed_through_account].inbox_url)&.enabled?
  end

  def reject_payload!
    Rails.logger.info("Rejected #{@json['type']} activity #{@json['id']} from #{@account.uri}#{@options[:relayed_through_account] && "via #{@options[:relayed_through_account].uri}"}")
    nil
  end
end
