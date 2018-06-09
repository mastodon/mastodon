# frozen_string_literal: true

class AccountDomainBlockWorker
  include Sidekiq::Worker

  def perform(account_id, domain)
    BlockDomainFromAccountService.new.call(Account.find(account_id), domain)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
