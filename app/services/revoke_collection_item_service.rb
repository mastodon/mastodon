# frozen_string_literal: true

class RevokeCollectionItemService < BaseService
  include Payloadable

  def call(collection_item)
    @collection_item = collection_item
    @account = collection_item.account
    @collection = @collection_item.collection

    @collection_item.revoke!

    distribute_stamp_deletion! if @collection_item.remote?
  end

  private

  def distribute_stamp_deletion!
    ActivityPub::DeliveryWorker.perform_async(signed_activity_json, @account.id, @collection.account.inbox_url)
    ActivityPub::AccountRawDistributionWorker.perform_async(signed_activity_json, @collection.account_id)
  end

  def signed_activity_json
    @signed_activity_json ||= serialize_payload(@collection_item, ActivityPub::DeleteFeatureAuthorizationSerializer, signer: @account, always_sign: true).to_json
  end
end
