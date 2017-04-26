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
      silence_accounts!
    else
      suspend_accounts!
    end
  end

  def silence_accounts!
    Account.where(domain: blocked_domain).update_all(silenced: true)
    clear_media! if domain_block.reject_media?
  end

  def clear_media!
    Account.where(domain: blocked_domain).find_each do |account|
      account.avatar.destroy
      account.header.destroy
    end

    MediaAttachment.where(account: Account.where(domain: blocked_domain)).reorder(nil).find_each do |attachment|
      attachment.file.destroy
    end
  end

  def suspend_accounts!
    Account.where(domain: blocked_domain).where(suspended: false).find_each do |account|
      account.subscription(api_subscription_url(account.id)).unsubscribe if account.subscribed?
      SuspendAccountService.new.call(account)
    end
  end

  def blocked_domain
    domain_block.domain
  end
end
