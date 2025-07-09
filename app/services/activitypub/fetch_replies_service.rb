# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  # Limit of fetched replies
  MAX_REPLIES = 5

  def call(reference_uri, collection_or_uri, max_pages: 1, allow_synchronous_requests: true, request_id: nil)
    @reference_uri = reference_uri
    @allow_synchronous_requests = allow_synchronous_requests

    @items, n_pages = collection_items(collection_or_uri, max_pages: max_pages)
    return if @items.nil?

    @items = filter_replies(@items)
    FetchReplyWorker.push_bulk(@items) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    [@items, n_pages]
  end

  private

  def collection_items(collection_or_uri, max_pages: 1)
    collection = fetch_collection(collection_or_uri)
    return unless collection.is_a?(Hash)

    collection = fetch_collection(collection['first']) if collection['first'].present?
    return unless collection.is_a?(Hash)

    items = []
    n_pages = 1
    while collection.is_a?(Hash)
      items.concat(as_array(collection_page_items(collection)))

      break if items.size >= MAX_REPLIES
      break if n_pages >= max_pages

      collection = collection['next'].present? ? fetch_collection(collection['next']) : nil
      n_pages += 1
    end

    [items, n_pages]
  end

  def collection_page_items(collection)
    case collection['type']
    when 'Collection', 'CollectionPage'
      collection['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      collection['orderedItems']
    end
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return unless @allow_synchronous_requests
    return if non_matching_uri_hosts?(@reference_uri, collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, nil, raise_on_error: :temporary)
  end

  def filter_replies(items)
    # Only fetch replies to the same server as the original status to avoid
    # amplification attacks.

    # Also limit to 5 fetched replies to limit potential for DoS.
    items.map { |item| value_or_id(item) }.reject { |uri| non_matching_uri_hosts?(@reference_uri, uri) }.take(MAX_REPLIES)
  end
end
