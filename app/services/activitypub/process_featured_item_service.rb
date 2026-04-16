# frozen_string_literal: true

class ActivityPub::ProcessFeaturedItemService
  include JsonLdHelper
  include Lockable
  include Redisable

  PROCESSING_DELAY = (30.seconds)..(10.minutes)

  def call(collection, uri_or_object, position: nil, request_id: nil)
    @collection = collection
    @request_id = request_id
    @item_json = uri_or_object.is_a?(String) ? fetch_resource(uri_or_object, true) : uri_or_object
    return if non_matching_uri_hosts?(@collection.uri, @item_json['id'])

    with_redis_lock("collection_item:#{@item_json['id']}") do
      @collection_item = existing_item || pre_approved_item || new_item

      @collection_item.update!(
        uri: @item_json['id'],
        object_uri: value_or_id(@item_json['featuredObject']),
        position:
      )

      @approval_uri = @item_json['featureAuthorization']

      verify_authorization! unless @collection_item&.account&.local?

      @collection_item
    end
  end

  private

  def existing_item
    @collection.collection_items.find_by(uri: @item_json['id'])
  end

  def pre_approved_item
    # This is a local account that has authorized this item already
    local_account = ActivityPub::TagManager.instance.uris_to_local_accounts([@item_json['featuredObject']]).first
    @collection.collection_items.accepted_partial(local_account).first if local_account.present?
  end

  def new_item
    @collection.collection_items.new(
      created_at: @item_json['published']
    )
  end

  def verify_authorization!
    ActivityPub::VerifyFeaturedItemService.new.call(@collection_item, @approval_uri, request_id: @request_id)
  rescue Mastodon::RecursionLimitExceededError, Mastodon::UnexpectedResponseError, *Mastodon::HTTP_CONNECTION_ERRORS
    ActivityPub::VerifyFeaturedItemWorker.perform_in(rand(PROCESSING_DELAY), @collection_item.id, @approval_uri, @request_id)
  end
end
