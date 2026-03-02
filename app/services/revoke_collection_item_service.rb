# frozen_string_literal: true

class RevokeCollectionItemService < BaseService
  include Payloadable

  def call(collection_item)
    @collection_item = collection_item
    @account = collection_item.account

    @collection_item.revoke!

    distribute_stamp_deletion! if Mastodon::Feature.collections_federation_enabled? && @collection_item.remote?
  end

  private

  def distribute_stamp_deletion!
    ActivityPub::AccountRawDistributionWorker.perform_async(signed_activity_json, @collection_item.collection.account_id)
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@collection_item, ActivityPub::DeleteFeatureAuthorizationSerializer, signer: @account, always_sign: true))
  end
end
