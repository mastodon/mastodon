# frozen_string_literal: true

class ActivityPub::Activity::Follow < ActivityPub::Activity
  def perform
    target_account = account_from_uri(object_uri)

    return if target_account.nil? || !target_account.local? || delete_arrived_first?(@json['id']) || @account.requested?(target_account)

    if target_account.blocking?(@account) || target_account.domain_blocking?(@account.domain)
      reject_follow_request!(target_account)
      return
    end

    # Fast-forward repeat follow requests
    if @account.following?(target_account)
      AuthorizeFollowService.new.call(@account, target_account, skip_follow_request: true, follow_request_uri: @json['id'])
      return
    end

    follow_request = FollowRequest.create!(account: @account, target_account: target_account, uri: @json['id'])

    if target_account.locked?
      NotifyService.new.call(target_account, follow_request)
    else
      AuthorizeFollowService.new.call(@account, target_account)
      NotifyService.new.call(target_account, ::Follow.find_by(account: @account, target_account: target_account))
    end
  end

  def reject_follow_request!(target_account)
    json = Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(FollowRequest.new(account: @account, target_account: target_account, uri: @json['id']), serializer: ActivityPub::RejectFollowSerializer, adapter: ActivityPub::Adapter).as_json).sign!(target_account))
    ActivityPub::DeliveryWorker.perform_async(json, target_account.id, @account.inbox_url)
  end
end
