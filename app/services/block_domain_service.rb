# frozen_string_literal: true

class BlockDomainService < BaseService
  def call(domain_block)
    if domain_block.silence?
      Account.where(domain: domain_block.domain).update_all(silenced: true)
    else
      Account.where(domain: domain_block.domain).find_each do |account|
        account.subscription(api_subscription_url(account.id)).unsubscribe if account.subscribed?
        SuspendAccountService.new.call(account)
      end
    end
  end
end
