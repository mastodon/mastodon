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
    blocked_domain_accounts.in_batches.update_all(silenced: true)
    clear_media! if domain_block.reject_media?
  end

  def clear_media!
    clear_account_images
    clear_account_attachments
  end

  def suspend_accounts!
    blocked_domain_accounts.where(suspended: false).find_each do |account|
      account.subscription(api_subscription_url(account.id)).unsubscribe if account.subscribed?
      SuspendAccountService.new.call(account)
    end
  end

  def clear_account_images
    blocked_domain_accounts.find_each do |account|
      account.avatar.destroy
      account.header.destroy
      account.save
    end
  end

  def clear_account_attachments
    media_from_blocked_domain.find_each do |attachment|
      attachment.file.destroy
      attachment.type = :unknown
      attachment.save
    end
  end

  def blocked_domain
    domain_block.domain
  end

  def blocked_domain_accounts
    Account.where(domain: blocked_domain)
  end

  def media_from_blocked_domain
    MediaAttachment.where(account: blocked_domain_accounts).reorder(nil)
  end
end
