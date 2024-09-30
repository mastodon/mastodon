# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  # Limit of fetched replies
  MAX_REPLIES = 5

  def call(parent_status, collection_or_uri, allow_synchronous_requests: true, request_id: nil, filter_by_host: true)
    @account = parent_status.account
    @allow_synchronous_requests = allow_synchronous_requests
    @filter_by_host = filter_by_host

    @items = collection_items(collection_or_uri)
    return if @items.nil?

    FetchReplyWorker.push_bulk(filtered_replies) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    @items
  end

  private

  def collection_items(collection_or_uri)
    collection = fetch_collection(collection_or_uri)
    return unless collection.is_a?(Hash)

    collection = fetch_collection(collection['first']) if collection['first'].present?
    return unless collection.is_a?(Hash)

    all_items = []
    while collection.is_a?(Hash)
      items = case collection['type']
              when 'Collection', 'CollectionPage'
                collection['items']
              when 'OrderedCollection', 'OrderedCollectionPage'
                collection['orderedItems']
              end

      all_items.concat(as_array(items))

      # Quit early if we are not fetching all replies
      break if all_items.size >= MAX_REPLIES

      collection = collection['next'].present? ? fetch_collection(collection['next']) : nil
    end

    all_items
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return unless @allow_synchronous_requests
    return if @filter_by_host && non_matching_uri_hosts?(@account.uri, collection_or_uri)

    # NOTE: For backward compatibility reasons, Mastodon signs outgoing
    # queries incorrectly by default.
    #
    # While this is relevant for all URLs with query strings, this is
    # the only code path where this happens in practice.
    #
    # Therefore, retry with correct signatures if this fails.
    begin
      fetch_resource_without_id_validation(collection_or_uri, nil, true)
    rescue Mastodon::UnexpectedResponseError => e
      raise unless e.response && e.response.code == 401 && Addressable::URI.parse(collection_or_uri).query.present?

      fetch_resource_without_id_validation(collection_or_uri, nil, true, request_options: { omit_query_string: false })
    end
  end

  def filtered_replies
    if @filter_by_host
      # Only fetch replies to the same server as the original status to avoid
      # amplification attacks.

      # Also limit to 5 fetched replies to limit potential for DoS.
      @items.map { |item| value_or_id(item) }.reject { |uri| non_matching_uri_hosts?(@account.uri, uri) }.take(MAX_REPLIES)
    else
      @items.map { |item| value_or_id(item) }.take(MAX_REPLIES)
    end
  end
end
