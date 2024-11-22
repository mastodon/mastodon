# frozen_string_literal: true

class ActivityPub::Activity::Accept < ActivityPub::Activity
  def perform
    return accept_follow_for_relay if relay_follow?
    return accept_follow!(follow_request_from_object) unless follow_request_from_object.nil?

    case @object['type']
    when 'Follow'
      accept_embedded_follow
    end
  end

  private

  def accept_embedded_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    follow_request = FollowRequest.find_by(account: target_account, target_account: @account)
    accept_follow!(follow_request)
  end

  def accept_follow!(request)
    return if request.nil?

    is_first_follow = !request.target_account.followers.local.exists?
    request.authorize!

    RemoteAccountRefreshWorker.perform_async(request.target_account_id) if is_first_follow
  end

  def accept_follow_for_relay
    relay.update!(state: :accepted)
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
