# frozen_string_literal: true

class ActivityPub::Activity::FeatureRequest < ActivityPub::Activity
  include Payloadable

  def perform
    return unless Mastodon::Feature.collections_enabled?
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    @collection = find_or_fetch_collection
    @featured_account = ActivityPub::TagManager.instance.uris_to_local_accounts([value_or_id(@json['object'])]).first

    return if @collection.nil? || @featured_account.nil?

    if AccountPolicy.new(@account, @featured_account).feature?
      accept_request!
    else
      reject_request!
    end
  end

  private

  def accept_request!
    collection_item = @collection.collection_items.create!(
      collection_item_attributes(:accepted)
    )

    notify_local_user!(collection_item)
    queue_delivery!(collection_item, ActivityPub::AcceptFeatureRequestSerializer)
  end

  def reject_request!
    collection_item = @collection.collection_items.build(
      collection_item_attributes(:rejected)
    )

    queue_delivery!(collection_item, ActivityPub::RejectFeatureRequestSerializer)
  end

  def find_or_fetch_collection
    uri = value_or_id(@json['instrument'])
    collection = @account.collections.find_by(uri:)
    return collection if collection.present?

    collection = ActivityPub::FetchRemoteFeaturedCollectionService.new.call(uri)
    return collection if collection.present? && collection.account == @account

    nil
  end

  def collection_item_attributes(state = :accepted)
    { account: @featured_account, activity_uri: @json['id'], state: }
  end

  def notify_local_user!(collection_item)
    LocalNotificationWorker.perform_async(collection_item.account_id, collection_item.id, collection_item.class.name, 'added_to_collection')
  end

  def queue_delivery!(collection_item, serializer)
    json = JSON.generate(serialize_payload(collection_item, serializer))
    ActivityPub::DeliveryWorker.perform_async(json, @featured_account.id, @account.inbox_url)
  end
end
