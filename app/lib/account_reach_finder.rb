# frozen_string_literal: true

class AccountReachFinder
  def initialize(account)
    @account = account
  end

  def inboxes
    (followers_inboxes + reporters_inboxes + recently_mentioned_inboxes + relay_inboxes).uniq
  end

  private

  def followers_inboxes
    @account.followers.inboxes
  end

  def reporters_inboxes
    Account.where(id: @account.targeted_reports.select(:account_id)).inboxes
  end

  def recently_mentioned_inboxes
    cutoff_id       = Mastodon::Snowflake.id_at(2.days.ago, with_random: false)
    recent_statuses = @account.statuses.recent.where(id: cutoff_id...).limit(200)

    Account.joins(:mentions).where(mentions: { status: recent_statuses }).inboxes.take(2000)
  end

  def relay_inboxes
    Relay.enabled.pluck(:inbox_url)
  end
end
