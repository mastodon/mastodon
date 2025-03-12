# frozen_string_literal: true

# Fetch all replies to a status, querying recursively through
# ActivityPub replies collections, fetching any statuses that
# we either don't already have or we haven't checked for new replies
# in the Status::FETCH_REPLIES_COOLDOWN_MINUTES interval
class ActivityPub::FetchAllRepliesWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  # Global max replies to fetch per request (all replies, recursively)
  MAX_REPLIES = (ENV['FETCH_REPLIES_MAX_GLOBAL'] || 1000).to_i
  MAX_PAGES = (ENV['FETCH_REPLIES_MAX_PAGES'] || 500).to_i

  def perform(root_status_id, options = {})
    @root_status = Status.remote.find_by(id: root_status_id)
    return unless @root_status&.should_fetch_replies?

    @root_status.touch(:fetched_replies_at)
    Rails.logger.debug { "FetchAllRepliesWorker - #{@root_status.uri}: Fetching all replies for status: #{@root_status}" }

    uris_to_fetch, n_pages = get_replies(@root_status.uri, MAX_PAGES, options)
    return if uris_to_fetch.nil?

    fetched_uris = uris_to_fetch.clone.to_set

    until uris_to_fetch.empty? || fetched_uris.length >= MAX_REPLIES || n_pages >= MAX_PAGES
      next_reply = uris_to_fetch.pop
      next if next_reply.nil?

      new_reply_uris, new_n_pages = get_replies(next_reply, MAX_PAGES - n_pages, options)
      next if new_reply_uris.nil?

      new_reply_uris = new_reply_uris.reject { |uri| fetched_uris.include?(uri) }

      uris_to_fetch.concat(new_reply_uris)
      fetched_uris = fetched_uris.merge(new_reply_uris)
      n_pages += new_n_pages
    end

    Rails.logger.debug { "FetchAllRepliesWorker - #{@root_status.uri}: fetched #{fetched_uris.length} replies" }

    # Workers shouldn't be returning anything, but this is used in tests
    fetched_uris
  end

  private

  def get_replies(status_uri, max_pages, options = {})
    replies_collection_or_uri = get_replies_uri(status_uri)
    return if replies_collection_or_uri.nil?

    ActivityPub::FetchAllRepliesService.new.call(status_uri, replies_collection_or_uri, max_pages: max_pages, **options.deep_symbolize_keys)
  end

  def get_replies_uri(parent_status_uri)
    fetch_resource(parent_status_uri, true)&.fetch('replies', nil)
  rescue => e
    Rails.logger.info { "FetchAllRepliesWorker - #{@root_status.uri}: Caught exception while resolving replies URI #{parent_status_uri}: #{e} - #{e.message}" }
    # Raise if we can't get the collection for top-level status to trigger retry
    raise e if parent_status_uri == @root_status.uri

    nil
  end
end
