# frozen_string_literal: true

class ActivityPub::Activity
  include JsonLdHelper

  def initialize(json, account, options = {})
    @json    = json
    @account = account
    @object  = @json['object']
    @options = options
  end

  def perform
    raise NotImplementedError
  end

  class << self
    def factory(json, account, options = {})
      @json = json
      klass&.new(json, account, options)
    end

    private

    def klass
      "ActivityPub::Activity::#{@json['type']}".constantize
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

  def redis
    Redis.current
  end

  def distribute(status)
    crawl_links(status)

    # Only continue if the status is supposed to have
    # arrived in real-time
    return unless @options[:override_timestamps]

    notify_about_reblog(status) if reblog_of_local_account?(status)
    notify_about_mentions(status)
    distribute_to_followers(status)
  end

  def reblog_of_local_account?(status)
    status.reblog? && status.reblog.account.local?
  end

  def notify_about_reblog(status)
    NotifyService.new.call(status.reblog.account, status)
  end

  def notify_about_mentions(status)
    status.mentions.includes(:account).each do |mention|
      next unless mention.account.local? && audience_includes?(mention.account)
      NotifyService.new.call(mention.account, mention)
    end
  end

  def crawl_links(status)
    return if status.spoiler_text?
    LinkCrawlWorker.perform_async(status.id)
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
end
