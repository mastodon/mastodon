# frozen_string_literal: true

class AuthorizeFollowService < BaseService
  def call(source_account, target_account)
    follow_request = FollowRequest.find_by!(account: source_account, target_account: target_account)
    follow_request.authorize!
    NotificationWorker.perform_async(build_xml(follow_request), target_account.id, source_account.id) unless source_account.local?
  end

  private

  def build_xml(follow_request)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request))
  end
end
