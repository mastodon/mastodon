# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  # Limit of fetched replies
  MAX_REPLIES = 5

  def call(reference_uri, collection_or_uri, max_pages: 1, allow_synchronous_requests: true, batch_id: nil, request_id: nil)
    @reference_uri = reference_uri
    return if !allow_synchronous_requests && !collection_or_uri.is_a?(Hash)

    # if given a prefetched collection while forbidding synchronous requests,
    # process it and return without fetching additional pages
    max_pages = 1 if !allow_synchronous_requests && collection_or_uri.is_a?(Hash)

    @items, n_pages = collection_items(collection_or_uri, max_pages: max_pages, max_items: MAX_REPLIES, reference_uri: @reference_uri)
    return if @items.nil?

    @items = filter_replies(@items)

    WorkerBatch.new(batch_id).within do |batch|
      FetchReplyWorker.push_bulk(@items) do |reply_uri|
        [reply_uri, { 'request_id' => request_id, 'batch_id' => batch.id }]
      end
    end

    [@items, n_pages]
  end

  private

  def filter_replies(items)
    # Only fetch replies to the same server as the original status to avoid
    # amplification attacks.

    # Also limit to 5 fetched replies to limit potential for DoS.
    items.map { |item| value_or_id(item) }.reject { |uri| non_matching_uri_hosts?(@reference_uri, uri) }.take(MAX_REPLIES)
  end
end
