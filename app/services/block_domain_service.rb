# frozen_string_literal: true

class BlockDomainService < BaseService
  def call(domain, severity)
    DomainBlock.where(domain: domain).first_or_create!(domain: domain, severity: severity)

    if severity == :silence
      Account.where(domain: domain).update_all(silenced: true)
    else
      Account.where(domain: domain).find_each do |account|
        account.subscription(api_subscription_url(account.id)).unsubscribe if account.subscribed?
        SuspendAccountService.new.call(account)
      end
    end
  end
end
