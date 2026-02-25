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

  # Max number of replies to fetch - total, recursively through a whole reply tree
  MAX_REPLIES = 1000
  # Max number of replies Collection pages to fetch - total
  MAX_PAGES = 500

  def perform(root_status_id, options = {})
    @batch = WorkerBatch.new(options['batch_id'])
    @root_status = Status.remote.find_by(id: root_status_id)

    return unless @root_status&.should_fetch_replies?

    @root_status.touch(:fetched_replies_at)
    Rails.logger.debug { "FetchAllRepliesWorker - #{@root_status.uri}: Fetching all replies for status: #{@root_status}" }

    uris_to_fetch, n_pages = get_root_replies(@root_status.uri, options)
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
  ensure
    @batch.remove_job(jid)
  end

  private

  # @param status [String, Hash]
  #   status URI, or the prefetched body of the Note object
  def get_replies(status, max_pages, options = {})
    replies_collection_or_uri = get_replies_uri(status)

    return if replies_collection_or_uri.nil?

    ActivityPub::FetchAllRepliesService.new.call(value_or_id(status), replies_collection_or_uri, max_pages: max_pages, **options.deep_symbolize_keys)
  end

  # Get the URI of the replies collection of a status
  #
  # @param parent_status [String, Hash]
  #   status URI, or the prefetched body of the Note object
  def get_replies_uri(parent_status)
    resource = parent_status.is_a?(Hash) ? parent_status : fetch_resource(parent_status, true)
    resource&.fetch('replies', nil)
  rescue => e
    Rails.logger.info { "FetchAllRepliesWorker - #{@root_status.uri}: Caught exception while resolving replies URI #{parent_status}: #{e} - #{e.message}" }
    # Raise if we can't get the collection for top-level status to trigger retry
    raise e if value_or_id(parent_status) == @root_status.uri

    nil
  end

  # Get the root status, updating the status without fetching it twice
  #
  # @param root_status_uri [String]
  def get_root_replies(root_status_uri, options = {})
    root_status_body = fetch_resource(root_status_uri, true)

    return if root_status_body.nil?

    FetchReplyWorker.perform_async(root_status_uri, { **options.deep_stringify_keys.except('batch_id'), 'prefetched_body' => root_status_body })

    get_replies(root_status_body, MAX_PAGES, options)
  end
end
