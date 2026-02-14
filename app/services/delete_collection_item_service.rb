# frozen_string_literal: true

class DeleteCollectionItemService
  def call(collection_item)
    @collection_item = collection_item
    @collection = collection_item.collection
    @collection_item.destroy!

    distribute_remove_activity if Mastodon::Feature.collections_federation_enabled?
  end

  private

  def distribute_remove_activity
    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @collection.account.id)
  end

  def activity_json
    ActiveModelSerializers::SerializableResource.new(@collection_item, serializer: ActivityPub::RemoveFeaturedItemSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
