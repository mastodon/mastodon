# frozen_string_literal: true

class RejectFollowService < BaseService
  include Payloadable

  def call(source_account, target_account)
    follow_request = FollowRequest.find_by!(account: source_account, target_account: target_account)
    follow_request.reject!
    create_notification(follow_request) unless source_account.local?
    follow_request
  end

  private

  def create_notification(follow_request)
    if follow_request.account.ostatus?
      NotificationWorker.perform_async(build_xml(follow_request), follow_request.target_account_id, follow_request.account_id)
    elsif follow_request.account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(follow_request), follow_request.target_account_id, follow_request.account.inbox_url)
    end
  end

  def build_json(follow_request)
    Oj.dump(serialize_payload(follow_request, ActivityPub::RejectFollowSerializer))
  end

  def build_xml(follow_request)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request))
  end
end
