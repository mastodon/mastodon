# frozen_string_literal: true

class UnallowDomainService < BaseService
  include DomainControlHelper

  def call(domain_allow)
    suspend_accounts!(domain_allow.domain) if limited_federation_mode?

    domain_allow.destroy
  end

  private

  def suspend_accounts!(domain)
    Account.where(domain: domain).in_batches.update_all(suspended_at: Time.now.utc)
    AfterUnallowDomainWorker.perform_async(domain)
  end
end
