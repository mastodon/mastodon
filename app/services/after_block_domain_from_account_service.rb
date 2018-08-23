# frozen_string_literal: true

class AfterBlockDomainFromAccountService < BaseService
  # This service does not create an AccountDomainBlock record,
  # it's meant to be called after such a record has been created
  # synchronously, to "clean up"
  def call(account, domain)
    @account = account
    @domain  = domain

    reject_existing_followers!
    reject_pending_follow_requests!
  end

  private

  def reject_existing_followers!
    @account.passive_relationships.where(account: Account.where(domain: @domain)).includes(:account).reorder(nil).find_each do |follow|
      reject_follow!(follow)
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

    json = Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      follow,
      serializer: ActivityPub::RejectFollowSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(@account))

    ActivityPub::DeliveryWorker.perform_async(json, @account.id, follow.account.inbox_url)
  end
end
