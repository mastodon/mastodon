# frozen_string_literal: true

class AfterAccountDomainBlockWorker < ApplicationWorker
  def perform(account_id, domain)
    AfterBlockDomainFromAccountService.new.call(Account.find(account_id), domain)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
