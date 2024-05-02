# frozen_string_literal: true

class AfterBlockDomainFromAccountService < BaseService
  include Payloadable

  # This service does not create an AccountDomainBlock record,
  # it's meant to be called after such a record has been created
  # synchronously, to "clean up"
  def call(account, domain)
    @account = account
    @domain  = domain
    @domain_block_event = nil

    clear_notifications!
    clear_notification_permissions!
    remove_follows!
    reject_existing_followers!
    reject_pending_follow_requests!
    notify_of_severed_relationships!
  end

  private

  def remove_follows!
    @account.active_relationships.where(target_account: Account.where(domain: @domain)).includes(:target_account).reorder(nil).in_batches do |follows|
      domain_block_event.import_from_active_follows!(follows)
      follows.each { |follow| UnfollowService.new.call(@account, follow.target_account) }
    end
  end

  def clear_notifications!
    Notification.where(account: @account).where(from_account: Account.where(domain: @domain)).in_batches.delete_all
  end

  def clear_notification_permissions!
    NotificationPermission.where(account: @account, from_account: Account.where(domain: @domain)).in_batches.delete_all
  end

  def reject_existing_followers!
    @account.passive_relationships.where(account: Account.where(domain: @domain)).includes(:account).reorder(nil).in_batches do |follows|
      domain_block_event.import_from_passive_follows!(follows)
      follows.each { |follow| reject_follow!(follow) }
    end
  end

  def reject_pending_follow_requests!
    FollowRequest.where(target_account: @account).where(account: Account.where(domain: @domain)).includes(:account).reorder(nil).find_each do |follow_request|
      reject_follow!(follow_request)
    end
  end

  def reject_follow!(follow)
    follow.destroy

    return unless follow.account.activitypub?

    ActivityPub::DeliveryWorker.perform_async(Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer)), @account.id, follow.account.inbox_url)
  end

  def notify_of_severed_relationships!
    return if @domain_block_event.nil?

    event = AccountRelationshipSeveranceEvent.create!(account: @account, relationship_severance_event: @domain_block_event)
    LocalNotificationWorker.perform_async(@account.id, event.id, 'AccountRelationshipSeveranceEvent', 'severed_relationships')
  end

  def domain_block_event
    @domain_block_event ||= RelationshipSeveranceEvent.create!(type: :user_domain_block, target_name: @domain)
  end
end
