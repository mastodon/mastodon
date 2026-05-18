# frozen_string_literal: true

class DeleteCollectionItemService
  def call(collection_item, revoke: false)
    @collection_item = collection_item
    @collection = collection_item.collection

    if collection_item.local?
      revoke ? @collection_item.revoke! : @collection_item.destroy!
      distribute_remove_activity
    else
      collection_item.destroy!
    end
  end

  private

  def distribute_remove_activity
    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @collection.account.id)
  end

  def activity_json
    ActiveModelSerializers::SerializableResource.new(@collection_item, serializer: ActivityPub::RemoveFeaturedItemSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
