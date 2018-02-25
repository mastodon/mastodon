# frozen_string_literal: true

class ActivityPub::Activity::Accept < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Follow'
      accept_follow
    end
  end

  private

  def accept_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    follow_request = FollowRequest.find_by(account: target_account, target_account: @account)
    follow_request&.authorize!
  end

  def target_uri
    @target_uri ||= value_or_id(@object['actor'])
  end
end
