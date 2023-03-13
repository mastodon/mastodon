# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  PAGE_LIMIT = 10
  REPLY_LIMIT = 100

  def call(parent_status, collection_or_uri, allow_synchronous_requests: true, request_id: nil)
    @account = parent_status.account
    @allow_synchronous_requests = allow_synchronous_requests

    @items = collection_items(collection_or_uri)
    return if @items.nil?

    FetchReplyWorker.push_bulk(filtered_replies) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    @items
  end

  private

  def collection_items(collection_or_uri)
    all_items = []
    page_count = 0

    collection = fetch_collection(collection_or_uri)
    return unless collection.is_a?(Hash)

    collection = fetch_collection(collection['first']) if collection['first'].present?

    while collection.is_a?(Hash) && page_count < PAGE_LIMIT
      page_count += 1

      items = case collection['type']
              when 'Collection', 'CollectionPage'
                collection['items']
              when 'OrderedCollection', 'OrderedCollectionPage'
                collection['orderedItems']
              else
                break
              end

      all_items.concat(items)
      break if all_items.size >= REPLY_LIMIT

      collection = collection['next'].present? ? fetch_collection(collection['next']) : nil
    end

    all_items
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return unless @allow_synchronous_requests
    return if invalid_origin?(collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, nil, true)
  end

  def filtered_replies
    @items.map { |item| value_or_id(item) }.reject { |uri| unsupported_uri_scheme?(uri) }.take(REPLY_LIMIT)
  end
end
