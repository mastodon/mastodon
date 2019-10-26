# frozen_string_literal: true

class BlockDomainService < BaseService
  attr_reader :domain_block

  def call(domain_block, update = false)
    @domain_block = domain_block
    process_domain_block!
    process_retroactive_updates! if update
  end

  private

  def process_retroactive_updates!
    # If the domain block severity has been changed, undo the appropriate limitations
    scope = Account.by_domain_and_subdomains(domain_block.domain)

    scope.where(silenced_at: domain_block.created_at).in_batches.update_all(silenced_at: nil) unless domain_block.silence?
    scope.where(suspended_at: domain_block.created_at).in_batches.update_all(suspended_at: nil) unless domain_block.suspend?
  end

  def process_domain_block!
    clear_media! if domain_block.reject_media?

    if domain_block.silence?
      silence_accounts!
    elsif domain_block.suspend?
      suspend_accounts!
    end
  end

  def invalidate_association_caches!
    # Normally, associated models of a status are immutable (except for accounts)
    # so they are aggressively cached. After updating the media attachments to no
    # longer point to a local file, we need to clear the cache to make those
    # changes appear in the API and UI
    @affected_status_ids.each { |id| Rails.cache.delete_matched("statuses/#{id}-*") }
  end

  def silence_accounts!
    blocked_domain_accounts.without_silenced.in_batches.update_all(silenced_at: @domain_block.created_at)
  end

  def clear_media!
    @affected_status_ids = []

    clear_account_images!
    clear_account_attachments!
    clear_emojos!

    invalidate_association_caches!
  end

  def suspend_accounts!
    blocked_domain_accounts.without_suspended.reorder(nil).find_each do |account|
      SuspendAccountService.new.call(account, reserve_username: true, suspended_at: @domain_block.created_at)
    end
  end

  def clear_account_images!
    blocked_domain_accounts.reorder(nil).find_each do |account|
      account.avatar.destroy if account.avatar.exists?
      account.header.destroy if account.header.exists?
      account.save
    end
  end

  def clear_account_attachments!
    media_from_blocked_domain.reorder(nil).find_each do |attachment|
      @affected_status_ids << attachment.status_id if attachment.status_id.present?

      attachment.file.destroy if attachment.file.exists?
      attachment.type = :unknown
      attachment.save
    end
  end

  def clear_emojos!
    emojis_from_blocked_domains.destroy_all
  end

  def blocked_domain
    domain_block.domain
  end

  def blocked_domain_accounts
    Account.by_domain_and_subdomains(blocked_domain)
  end

  def media_from_blocked_domain
    MediaAttachment.joins(:account).merge(blocked_domain_accounts).reorder(nil)
  end

  def emojis_from_blocked_domains
    CustomEmoji.by_domain_and_subdomains(blocked_domain)
  end
end
