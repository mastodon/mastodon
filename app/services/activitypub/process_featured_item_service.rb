# frozen_string_literal: true

class ActivityPub::ProcessFeaturedItemService
  include JsonLdHelper
  include Lockable
  include Redisable

  def call(collection, uri_or_object)
    item_json = uri_or_object.is_a?(String) ? fetch_resource(uri_or_object, true) : uri_or_object
    return if non_matching_uri_hosts?(collection.uri, item_json['id'])

    with_redis_lock("collection_item:#{item_json['id']}") do
      return if collection.collection_items.exists?(uri: item_json['id'])

      local_account = ActivityPub::TagManager.instance.uris_to_local_accounts([item_json['featuredObject']]).first

      if local_account.present?
        # This is a local account that has authorized this item already
        @collection_item = collection.collection_items.accepted_partial(local_account).first
        @collection_item&.update!(uri: item_json['id'])
      else
        @collection_item = collection.collection_items.create!(
          uri: item_json['id'],
          object_uri: item_json['featuredObject'],
          approval_uri: item_json['featureAuthorization']
        )

        verify_authorization!
      end

      @collection_item
    end
  end

  private

  def verify_authorization!
    ActivityPub::VerifyFeaturedItemService.new.call(@collection_item)
  rescue Mastodon::RecursionLimitExceededError, Mastodon::UnexpectedResponseError, *Mastodon::HTTP_CONNECTION_ERRORS
    ActivityPub::VerifyFeaturedItemWorker.perform_in(rand(30..600).seconds, @collection_item.id)
  end
end
