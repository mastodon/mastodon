# frozen_string_literal: true

class BlockDomainService < BaseService
  attr_reader :domain_block

  def call(domain_block, update: false)
    @domain_block = domain_block
    @domain_block_event = nil

    process_domain_block!
    process_retroactive_updates! if update
    notify_of_severed_relationships!
  end

  private

  def process_retroactive_updates!
    # If the domain block severity has been changed, undo the appropriate limitations
    scope = Account.by_domain_and_subdomains(domain_block.domain)

    scope.where(silenced_at: domain_block.created_at).in_batches.update_all(silenced_at: nil) unless domain_block.silence?
    scope.where(suspended_at: domain_block.created_at).in_batches.update_all(suspended_at: nil, suspension_origin: nil) unless domain_block.suspend?
  end

  def process_domain_block!
    if domain_block.silence?
      silence_accounts!
    elsif domain_block.suspend?
      suspend_accounts!
    end

    if domain_block.suspend?
      # Account images and attachments are already handled by `suspend_accounts!`
      PurgeCustomEmojiWorker.perform_async(blocked_domain)
    elsif domain_block.reject_media?
      DomainClearMediaWorker.perform_async(domain_block.id)
    end
  end

  def silence_accounts!
    blocked_domain_accounts.without_silenced.in_batches.update_all(silenced_at: @domain_block.created_at)
  end

  def suspend_accounts!
    blocked_domain_accounts.without_suspended.in_batches.update_all(suspended_at: @domain_block.created_at, suspension_origin: :local)

    blocked_domain_accounts.where(suspended_at: @domain_block.created_at).reorder(nil).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: true, suspended_at: @domain_block.created_at, relationship_severance_event: domain_block_event)
    end
  end

  def notify_of_severed_relationships!
    return if @domain_block_event.nil?

    # find_in_batches and perform_bulk both default to batches of 1000
    @domain_block_event.affected_local_accounts.reorder(nil).find_in_batches do |accounts|
      notification_jobs_args = accounts.map do |account|
        event = AccountRelationshipSeveranceEvent.create!(account:, relationship_severance_event: @domain_block_event)
        [account.id, event.id, 'AccountRelationshipSeveranceEvent', 'severed_relationships']
      end

      LocalNotificationWorker.perform_bulk(notification_jobs_args)
    end
  end

  def blocked_domain
    domain_block.domain
  end

  def domain_block_event
    @domain_block_event ||= RelationshipSeveranceEvent.create!(type: :domain_block, target_name: blocked_domain)
  end

  def blocked_domain_accounts
    Account.by_domain_and_subdomains(blocked_domain)
  end
end
