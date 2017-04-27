# frozen_string_literal: true

class RejectFollowService < BaseService
  def call(source_account, target_account)
    follow_request = FollowRequest.find_by!(account: source_account, target_account: target_account)
    follow_request.reject!
    NotificationWorker.perform_async(build_xml(follow_request), target_account.id, source_account.id) unless source_account.local?
  end

  private

  def build_xml(follow_request)
    AtomSerializer.render(AtomSerializer.new.reject_follow_request_salmon(follow_request))
  end
end
