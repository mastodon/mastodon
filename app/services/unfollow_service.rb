class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    NotificationWorker.perform_async(follow.stream_entry.id, target_account.id) unless target_account.local?
  end
end
