class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    send_interaction_service.(follow.stream_entry, target_account) unless target_account.local?
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
