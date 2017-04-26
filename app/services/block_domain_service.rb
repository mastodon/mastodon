# frozen_string_literal: true

class BlockDomainService < BaseService
  attr_reader :domain_block

  def call(domain_block)
    @domain_block = domain_block
    process_domain_block
  end

  private

  def process_domain_block
    if domain_block.silence?
      silence_accounts!(domain_block.domain)
    else
      suspend_accounts!(domain_block.domain)
    end
  end

  def silence_accounts!(domain)
    Account.where(domain: domain).update_all(silenced: true)
    clear_media!(domain_block.domain) if domain_block.reject_media?
  end

  def clear_media!(domain)
    Account.where(domain: domain).find_each do |account|
      account.avatar.destroy
      account.header.destroy
    end

    MediaAttachment.where(account: Account.where(domain: domain)).reorder(nil).find_each do |attachment|
      attachment.file.destroy
    end
  end

  def suspend_accounts!(domain)
    Account.where(domain: domain).where(suspended: false).find_each do |account|
      account.subscription(api_subscription_url(account.id)).unsubscribe if account.subscribed?
      SuspendAccountService.new.call(account)
    end
  end
end
