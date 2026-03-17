# frozen_string_literal: true

class ActivityPub::Activity::FeatureRequest < ActivityPub::Activity
  include Payloadable

  def perform
    return unless Mastodon::Feature.collections_federation_enabled?
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    @collection = @account.collections.find_by(uri: value_or_id(@json['instrument']))
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
      account: @featured_account,
      state: :accepted
    )

    queue_delivery!(collection_item, ActivityPub::AcceptFeatureRequestSerializer)
  end

  def reject_request!
    collection_item = @collection.collection_items.build(
      account: @featured_account,
      state: :rejected
    )

    queue_delivery!(collection_item, ActivityPub::RejectFeatureRequestSerializer)
  end

  def queue_delivery!(collection_item, serializer)
    json = JSON.generate(serialize_payload(collection_item, serializer))
    ActivityPub::DeliveryWorker.perform_async(json, @featured_account.id, @account.inbox_url)
  end
end
