# frozen_string_literal: true

class UpdateCollectionService
  UPDATEABLE_PARAMS = %w(name description language sensitive discoverable tag_id).freeze

  def call(collection, params)
    @collection = collection
    @collection.update!(params)

    notify_about_update if %i(description name).any? { |attr| @collection.attribute_previously_changed?(attr) }
    distribute_update_activity
  end

  private

  def distribute_update_activity
    return unless relevant_attributes_changed?

    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @collection.account.id)
  end

  def notify_about_update
    @collection.collection_items.includes(:account).references(:account).merge(Account.local).accepted.find_each do |collection_item|
      LocalNotificationWorker.perform_async(collection_item.account_id, @collection.id, @collection.class.name, 'collection_update')
    end
  end

  def activity_json
    ActiveModelSerializers::SerializableResource.new(@collection, serializer: ActivityPub::UpdateFeaturedCollectionSerializer, adapter: ActivityPub::Adapter).to_json
  end

  def relevant_attributes_changed?
    (@collection.saved_changes.keys & UPDATEABLE_PARAMS).any?
  end
end
