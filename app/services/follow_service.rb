# frozen_string_literal: true

class FollowService < BaseService
  include Redisable
  include Payloadable
  include DomainControlHelper

  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [Account] target_account Account to follow
  # @param [Hash] options
  # @option [Boolean] :reblogs Whether or not to show reblogs, defaults to true
  # @option [Boolean] :notify Whether to create notifications about new posts, defaults to false
  # @option [Array<String>] :languages Which languages to allow on the home feed from this account, defaults to all
  # @option [Boolean] :bypass_locked
  # @option [Boolean] :bypass_limit Allow following past the total follow number
  # @option [Boolean] :with_rate_limit
  def call(source_account, target_account, options = {})
    @source_account = source_account
    @target_account = target_account
    @options        = { bypass_locked: false, bypass_limit: false, with_rate_limit: false }.merge(options)

    raise ActiveRecord::RecordNotFound if following_not_possible?
    raise Mastodon::NotPermittedError  if following_not_allowed?

    if @source_account.following?(@target_account)
      return change_follow_options!
    elsif @source_account.requested?(@target_account)
      return change_follow_request_options!
    end

    ActivityTracker.increment('activity:interactions')

    # When an account follows someone for the first time, avoid showing
    # an empty home feed while the follow request is being processed
    # and the feeds are being merged
    mark_home_feed_as_partial! if @source_account.not_following_anyone?

    if (@target_account.locked? && !@options[:bypass_locked]) || @source_account.silenced? || @target_account.activitypub?
      request_follow!
    elsif @target_account.local?
      direct_follow!
    end
  end

  private

  def mark_home_feed_as_partial!
    redis.set("account:#{@source_account.id}:regeneration", true, nx: true, ex: 1.day.seconds)
  end

  def following_not_possible?
    @target_account.nil? || @target_account.id == @source_account.id || @target_account.unavailable?
  end

  def following_not_allowed?
    domain_not_allowed?(@target_account.domain) || @target_account.blocking?(@source_account) || @source_account.blocking?(@target_account) || @target_account.moved? || (!@target_account.local? && @target_account.ostatus?) || @source_account.domain_blocking?(@target_account.domain)
  end

  def change_follow_options!
    @source_account.follow!(@target_account, **follow_options)
  end

  def change_follow_request_options!
    @source_account.request_follow!(@target_account, **follow_options)
  end

  def request_follow!
    follow_request = @source_account.request_follow!(@target_account, **follow_options.merge(rate_limit: @options[:with_rate_limit], bypass_limit: @options[:bypass_limit]))

    if @target_account.local?
      LocalNotificationWorker.perform_async(@target_account.id, follow_request.id, follow_request.class.name, 'follow_request')
    elsif @target_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(follow_request), @source_account.id, @target_account.inbox_url, { 'bypass_availability' => true })
    end

    follow_request
  end

  def direct_follow!
    follow = @source_account.follow!(@target_account, **follow_options.merge(rate_limit: @options[:with_rate_limit], bypass_limit: @options[:bypass_limit]))

    LocalNotificationWorker.perform_async(@target_account.id, follow.id, follow.class.name, 'follow')
    MergeWorker.perform_async(@target_account.id, @source_account.id, 'home')
    MergeWorker.push_bulk(List.where(account: @source_account).joins(:list_accounts).where(list_accounts: { account_id: @target_account.id }).pluck(:id)) do |list_id|
      [@target_account.id, list_id, 'list']
    end

    follow
  end

  def build_json(follow_request)
    Oj.dump(serialize_payload(follow_request, ActivityPub::FollowSerializer))
  end

  def follow_options
    @options.slice(:reblogs, :notify, :languages)
  end
end
