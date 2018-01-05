# frozen_string_literal: true

class ActivityPub::Activity::Accept < ActivityPub::Activity
  def perform
    if @object.respond_to?(:[]) &&
       @object['type'] == 'Follow' && @object['actor'].present?
      accept_follow_from @object['actor']
    else
      accept_follow_object @object
    end
  end

  private

  def accept_follow_from(actor)
    target_account = account_from_uri(value_or_id(actor))

    return if target_account.nil? || !target_account.local?

    follow_request = FollowRequest.find_by(account: target_account, target_account: @account)
    follow_request&.authorize!
  end

  def accept_follow_object(object)
    follow_request = ActivityPub::TagManager.instance.uri_to_resource(value_or_id(object), FollowRequest)
    follow_request&.authorize!
  end
end
