# frozen_string_literal: true

class UnfollowService < BaseService
  include StreamEntryRenderer

  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    NotificationWorker.perform_async(stream_entry_to_xml(follow.stream_entry), source_account.id, target_account.id) unless target_account.local?
    UnmergeWorker.perform_async(target_account.id, source_account.id)
  end
end
