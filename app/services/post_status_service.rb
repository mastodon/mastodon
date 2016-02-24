class PostStatusService < BaseService
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
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
