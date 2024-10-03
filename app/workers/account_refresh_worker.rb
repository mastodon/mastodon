# frozen_string_literal: true

class AccountRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 3, dead: false, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(account_id)
    account = Account.find_by(id: account_id)
    return if account.nil? || account.last_webfingered_at > Account::BACKGROUND_REFRESH_INTERVAL.ago

    ResolveAccountService.new.call(account)
  end
end
