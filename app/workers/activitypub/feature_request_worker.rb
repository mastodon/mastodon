# frozen_string_literal: true

class ActivityPub::FeatureRequestWorker < ActivityPub::RawDistributionWorker
  def perform(collection_item_id)
    @collection_item = CollectionItem.find(collection_item_id)
    @account = @collection_item.collection.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= [@collection_item.account.inbox_url]
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@collection_item, ActivityPub::FeatureRequestSerializer, signer: @account))
  end
end
