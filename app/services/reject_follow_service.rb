# frozen_string_literal: true

class RejectFollowService < BaseService
  include StreamEntryRenderer

  def call(source_account, target_account)
    follow_request = FollowRequest.find_by!(account: source_account, target_account: target_account)
    follow_request.reject!
    NotificationWorker.perform_async(stream_entry_to_xml(follow_request.stream_entry), target_account.id, source_account.id) unless source_account.local?
    follow_request.stream_entry.destroy
  end
end
