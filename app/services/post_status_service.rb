class PostStatusService < BaseService
  # Post a text status update, fetch and notify remote users mentioned
  # @param [Account] account Account from which to post
  # @param [String] text Message
  # @param [Status] in_reply_to Optional status to reply to
  # @return [Status]
  def call(account, text, in_reply_to = nil)
    status = account.statuses.create!(text: text, thread: in_reply_to)

    status.text.scan(Account::MENTION_RE).each do |match|
      next if match.first.split('@').size == 1
      username, domain = match.first.split('@')
      local_account = Account.find_by(username: username, domain: domain)
      next unless local_account.nil?
      follow_remote_account_service.("acct:#{match.first}")
    end

    status.mentions.each do |mentioned_account|
      next if mentioned_account.local?
      send_interaction_service.(status.stream_entry, mentioned_account)
    end

    status
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
