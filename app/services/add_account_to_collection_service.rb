# frozen_string_literal: true

class AddAccountToCollectionService
  def call(collection, account)
    raise ArgumentError unless collection.local?

    @collection = collection
    @account = account

    raise Mastodon::NotPermittedError, I18n.t('accounts.errors.cannot_be_added_to_collections') unless AccountPolicy.new(@collection.account, @account).feature?

    @collection_item = create_collection_item

    if Mastodon::Feature.collections_federation_enabled?
      distribute_add_activity if @account.local?
      distribute_feature_request_activity if @account.remote?
    end

    @collection_item
  end

  private

  def create_collection_item
    @collection.collection_items.create!(
      account: @account,
      state: :accepted
    )
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
