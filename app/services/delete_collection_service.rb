# frozen_string_literal: true

class DeleteCollectionService
  def call(collection)
    @collection = collection
    @account_ids = @collection.account_ids
    @collection.destroy!

    distribute_remove_activity
  end

  private

  def distribute_remove_activity
    @account_ids.each do |account_id|
      ActivityPub::DeliveryWorker.perform_async(activity_json, account_id, @collection.account.inbox_url)
    end
    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @collection.account_id)
  end

  def activity_json
    @activity_json ||= ActiveModelSerializers::SerializableResource.new(@collection, serializer: ActivityPub::RemoveFeaturedCollectionSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
