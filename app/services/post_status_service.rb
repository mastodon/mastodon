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
  end

  private

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end
end
