# frozen_string_literal: true

class ActivityPub::Activity::Reject < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Follow'
      reject_follow
    end
  end

  private

  def reject_follow
    return reject_follow_for_relay if relay_follow?

    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    follow_request = FollowRequest.find_by(account: target_account, target_account: @account)
    follow_request&.reject!

    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)
  end

  def reject_follow_for_relay
    relay.update!(state: :rejected)
  end

  def relay
    @relay ||= Relay.find_by(follow_activity_id: object_uri) unless object_uri.nil?
  end

  def relay_follow?
    relay.present?
  end

  def target_uri
    @target_uri ||= value_or_id(@object['actor'])
  end
end
