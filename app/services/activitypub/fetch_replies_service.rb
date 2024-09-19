# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  # Limit of fetched replies used when not fetching all replies
  MAX_REPLIES_LOW = 5
  # limit of fetched replies used when fetching all replies
  MAX_REPLIES_HIGH = 500

  def call(parent_status, collection_or_uri, allow_synchronous_requests: true, request_id: nil, all_replies: false)
    # Whether we are getting replies from more than the originating server,
    # and don't limit ourselves to getting at most `MAX_REPLIES_LOW`
    @all_replies = all_replies
    # store the status and whether we should fetch replies for it to avoid
    # race conditions if something else updates us in the meantime
    @status = parent_status
    @should_fetch_replies = parent_status.should_fetch_replies?

    @account = parent_status.account
    @allow_synchronous_requests = allow_synchronous_requests

    @items = collection_items(collection_or_uri)
    return if @items.nil?

    FetchReplyWorker.push_bulk(filtered_replies) { |reply_uri| [reply_uri, { 'request_id' => request_id }, @all_replies] }
    # Store last fetched all to debounce
    @status.update(fetched_replies_at: Time.now.utc) if fetch_all_replies?

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
      break if all_items.size >= MAX_REPLIES_HIGH || !fetch_all_replies?

      collection = collection['next'].present? ? fetch_collection(collection['next']) : nil
    end

    all_items
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return unless @allow_synchronous_requests
    return if !@all_replies && non_matching_uri_hosts?(@account.uri, collection_or_uri)

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
    if @all_replies
      # Reject all statuses that we already have in the db
      @items.map { |item| value_or_id(item) }.reject { |uri| Status.exists?(uri: uri) }
    else
      # Only fetch replies to the same server as the original status to avoid
      # amplification attacks.

      # Also limit to 5 fetched replies to limit potential for DoS.
      @items.map { |item| value_or_id(item) }.reject { |uri| non_matching_uri_hosts?(@account.uri, uri) }.take(MAX_REPLIES_LOW)
    end
  end

  def fetch_all_replies?
    @all_replies && @should_fetch_replies
  end
end
