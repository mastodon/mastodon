# frozen_string_literal: true

class DeleteCollectionService
  def call(collection)
    @collection = collection
    @collection.destroy!

    distribute_remove_activity if Mastodon::Feature.collections_federation_enabled?
  end

  private

  def distribute_remove_activity
    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @collection.account.id)
  end

  def activity_json
    ActiveModelSerializers::SerializableResource.new(@collection, serializer: ActivityPub::RemoveFeaturedCollectionSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
