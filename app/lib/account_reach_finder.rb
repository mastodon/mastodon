# frozen_string_literal: true

class AccountReachFinder
  def initialize(account, options = {})
    @account = account
    @options = options
  end

  def inboxes
    (followers_inboxes + reporters_inboxes + blocked_by_inboxes + relay_inboxes).uniq
  end

  private

  def followers_inboxes
    @account.followers.inboxes
  end

  def reporters_inboxes
    Account.where(id: @account.targeted_reports.select(:account_id)).inboxes
  end

  def blocked_by_inboxes
    if @options[:with_blocking_accounts]
      @account.blocked_by.inboxes
    else
      []
    end
  end

  def relay_inboxes
    Relay.enabled.pluck(:inbox_url)
  end
end
