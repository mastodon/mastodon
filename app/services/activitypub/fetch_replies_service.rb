# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  # Limit of fetched replies
  MAX_REPLIES = 5

  def call(parent_status, collection_or_uri, allow_synchronous_requests: true, request_id: nil, filter_by_host: true)
    @account = parent_status.account
    @allow_synchronous_requests = allow_synchronous_requests
    @filter_by_host = filter_by_host

    return if @filter_by_host && non_matching_uri_hosts?(@account.uri, collection_or_uri)
    return if @allow_synchronous_requests && !collection_or_uri.is_a?(Hash)

    @items = collection_items(collection_or_uri, MAX_REPLIES)
    return if @items.nil?

    FetchReplyWorker.push_bulk(filtered_replies) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    @items
  end

  private

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
