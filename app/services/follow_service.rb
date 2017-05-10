# frozen_string_literal: true

class FollowService < BaseService
  include StreamEntryRenderer

  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String] uri User URI to follow in the form of username@domain
  def call(source_account, uri)
    target_account = FollowRemoteAccountService.new.call(uri)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id || target_account.suspended?
    raise Mastodon::NotPermittedError  if target_account.blocking?(source_account) || source_account.blocking?(target_account)

    if target_account.locked?
      request_follow(source_account, target_account)
    else
      direct_follow(source_account, target_account)
    end
  end

  private

  def request_follow(source_account, target_account)
    follow_request = FollowRequest.create!(account: source_account, target_account: target_account)

    if target_account.local?
      NotifyService.new.call(target_account, follow_request)
    else
      NotificationWorker.perform_async(build_follow_request_xml(follow_request), source_account.id, target_account.id)
      AfterRemoteFollowRequestWorker.perform_async(follow_request.id)
    end

    follow_request
  end

  def direct_follow(source_account, target_account)
    follow = source_account.follow!(target_account)

    if target_account.local?
      NotifyService.new.call(target_account, follow)
    else
      Pubsubhubbub::SubscribeWorker.perform_async(target_account.id) unless target_account.subscribed?
      NotificationWorker.perform_async(build_follow_xml(follow), source_account.id, target_account.id)
      AfterRemoteFollowWorker.perform_async(follow.id)
    end

    MergeWorker.perform_async(target_account.id, source_account.id)

    follow
  end

  def redis
    Redis.current
  end

  def build_follow_request_xml(follow_request)
    AtomSerializer.render(AtomSerializer.new.follow_request_salmon(follow_request))
  end

  def build_follow_xml(follow)
    AtomSerializer.render(AtomSerializer.new.follow_salmon(follow))
  end
end
