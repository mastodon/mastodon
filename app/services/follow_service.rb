# frozen_string_literal: true

class FollowService < BaseService
  include Redisable
  include Payloadable

  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String, Account] uri User URI to follow in the form of username@domain (or account record)
  # @param [true, false, nil] reblogs Whether or not to show reblogs, defaults to true
  def call(source_account, target_account, reblogs: nil, bypass_locked: false)
    reblogs = true if reblogs.nil?
    target_account = ResolveAccountService.new.call(target_account, skip_webfinger: true)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id || target_account.suspended?
    raise Mastodon::NotPermittedError  if target_account.blocking?(source_account) || source_account.blocking?(target_account) || target_account.moved? || (!target_account.local? && target_account.ostatus?) || source_account.domain_blocking?(target_account.domain)

    if source_account.following?(target_account)
      # We're already following this account, but we'll call follow! again to
      # make sure the reblogs status is set correctly.
      return source_account.follow!(target_account, reblogs: reblogs)
    elsif source_account.requested?(target_account)
      # This isn't managed by a method in AccountInteractions, so we modify it
      # ourselves if necessary.
      req = source_account.follow_requests.find_by(target_account: target_account)
      req.update!(show_reblogs: reblogs)
      return req
    end

    ActivityTracker.increment('activity:interactions')

    if (target_account.locked? && !bypass_locked) || source_account.silenced? || target_account.activitypub?
      request_follow(source_account, target_account, reblogs: reblogs)
    elsif target_account.local?
      direct_follow(source_account, target_account, reblogs: reblogs)
    end
  end

  private

  def request_follow(source_account, target_account, reblogs: true)
    follow_request = FollowRequest.create!(account: source_account, target_account: target_account, show_reblogs: reblogs)

    if target_account.local?
      LocalNotificationWorker.perform_async(target_account.id, follow_request.id, follow_request.class.name)
    elsif target_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(follow_request), source_account.id, target_account.inbox_url)
    end

    follow_request
  end

  def direct_follow(source_account, target_account, reblogs: true)
    follow = source_account.follow!(target_account, reblogs: reblogs)

    LocalNotificationWorker.perform_async(target_account.id, follow.id, follow.class.name)
    MergeWorker.perform_async(target_account.id, source_account.id)

    follow
  end

  def build_json(follow_request)
    Oj.dump(serialize_payload(follow_request, ActivityPub::FollowSerializer))
  end
end
