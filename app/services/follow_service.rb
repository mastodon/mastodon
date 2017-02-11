# frozen_string_literal: true

class FollowService < BaseService
  include StreamEntryRenderer

  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String] uri User URI to follow in the form of username@domain
  def call(source_account, uri)
    target_account = FollowRemoteAccountService.new.call(uri)

    raise ActiveRecord::RecordNotFound if target_account.nil? || target_account.id == source_account.id || target_account.suspended?
    raise Mastodon::NotPermitted       if target_account.blocking?(source_account) || source_account.blocking?(target_account)

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
      SubscribeService.new.call(target_account) unless target_account.subscribed?
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
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        title xml, "#{follow_request.account.acct} requested to follow #{follow_request.target_account.acct}"

        author(xml) do
          include_author xml, follow_request.account
        end

        object_type xml, :activity
        verb xml, :request_friend

        target(xml) do
          include_author xml, follow_request.target_account
        end
      end
    end.to_xml
  end

  def build_follow_xml(follow)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        title xml, "#{follow.account.acct} started following #{follow.target_account.acct}"

        author(xml) do
          include_author xml, follow.account
        end

        object_type xml, :activity
        verb xml, :follow

        target(xml) do
          include_author xml, follow.target_account
        end
      end
    end.to_xml
  end
end
