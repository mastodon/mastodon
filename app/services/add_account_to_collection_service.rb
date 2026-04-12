# frozen_string_literal: true

class AddAccountToCollectionService
  def call(collection, account)
    raise ArgumentError unless collection.local?

    @collection = collection
    @account = account

    raise Mastodon::NotPermittedError, I18n.t('accounts.errors.cannot_be_added_to_collections') unless AccountPolicy.new(@collection.account, @account).feature?

    @collection_item = create_collection_item

    notify_local_user if @account.local?
    distribute_add_activity if @account.local?
    distribute_feature_request_activity if @account.remote?

    @collection_item
  end

  private

  def create_collection_item
    state = @account.local? ? :accepted : :pending
    @collection.collection_items.create!(account: @account, state:)
  end

  def notify_local_user
    LocalNotificationWorker.perform_async(@account.id, @collection_item.id, @collection_item.class.name, 'added_to_collection')
  end

  def distribute_add_activity
    ActivityPub::AccountRawDistributionWorker.perform_async(add_activity_json, @collection.account_id)
  end

  def distribute_feature_request_activity
    ActivityPub::FeatureRequestWorker.perform_async(@collection_item.id)
  end

  def add_activity_json
    ActiveModelSerializers::SerializableResource.new(@collection_item, serializer: ActivityPub::AddFeaturedItemSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
