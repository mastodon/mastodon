class FollowService < BaseService
  # Follow a remote user, notify remote user about the follow
  # @param [Account] source_account From which to follow
  # @param [String] uri User URI to follow in the form of username@domain
  def call(source_account, uri)
    target_account = follow_remote_account_service.(uri)

    return if target_account.nil?

    follow = source_account.follow!(target_account)
    send_interaction_service.(follow.stream_entry, target_account)
    source_account.ping!(atom_user_stream_url(id: source_account.id), HUB_URL)
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
