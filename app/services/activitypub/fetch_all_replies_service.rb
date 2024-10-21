# frozen_string_literal: true

class ActivityPub::FetchAllRepliesService < ActivityPub::FetchRepliesService
  include JsonLdHelper

  # Limit of replies to fetch per status
  MAX_REPLIES = (ENV['FETCH_REPLIES_MAX_SINGLE'] || 500).to_i

  def call(collection_or_uri, allow_synchronous_requests: true, request_id: nil)
    @allow_synchronous_requests = allow_synchronous_requests
    @filter_by_host = false
    @collection_or_uri = collection_or_uri

    @items = collection_items(collection_or_uri)
    @items = filtered_replies
    return if @items.nil?

    FetchReplyWorker.push_bulk(@items) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    @items
  end

  private

  def filtered_replies
    return if @items.nil?

    # Find all statuses that we *shouldn't* update the replies for, and use that as a filter.
    # We don't assume that we have the statuses before they're created,
    # hence the negative filter -
    # "keep all these uris except the ones we already have"
    # instead of
    # "keep all these uris that match some conditions on existing Status objects"
    #
    # Typically we assume the number of replies we *shouldn't* fetch is smaller than the
    # replies we *should* fetch, so we also minimize the number of uris we should load here.
    uris = @items.map { |item| value_or_id(item) }
    dont_update = Status.where(uri: uris).shouldnt_fetch_replies.pluck(:uri)

    # touch all statuses that already exist and that we're about to update
    Status.where(uri: uris).should_fetch_replies.touch_all(:fetched_replies_at)

    # Reject all statuses that we already have in the db
    uris = uris.reject { |uri| dont_update.include?(uri) }.take(MAX_REPLIES)

    Rails.logger.debug { "FetchAllRepliesService - #{@collection_or_uri}: Fetching filtered statuses: #{uris}" }
    uris
  end
end
