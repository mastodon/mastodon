# frozen_string_literal: true

# Fetch all replies to a status, querying recursively through
# ActivityPub replies collections, fetching any statuses that
# we either don't already have or we haven't checked for new replies
# in the Status::FETCH_REPLIES_DEBOUNCE interval
class ActivityPub::FetchAllRepliesWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  # Global max replies to fetch per request
  MAX_REPLIES = 1000

  def perform(parent_status_id, options = {})
    @parent_status = Status.find(parent_status_id)
    @current_account_id = options.fetch(:current_account_id, nil)
    @current_account = @current_account_id.nil? ? nil : Account.find(id: @current_account_id)

    all_replies = get_replies(@parent_status.uri)
    got_replies = all_replies.length
    until all_replies.empty? || got_replies >= MAX_REPLIES
      new_replies = get_replies(all_replies.pop)
      got_replies += new_replies.length
      all_replies << new_replies
    end
  end

  private

  def get_replies(status_uri)
    replies_uri = get_replies_uri(status_uri)
    return if replies_uri.nil?

    ActivityPub::FetchAllRepliesService.new.call(replies_uri, **options.deep_symbolize_keys)
  end

  def get_replies_uri(parent_status_uri)
    json_status = fetch_resource(parent_status_uri, true, @current_account)
    replies_uri = json_status['replies']
    Rails.logger.debug { "Could not find replies uri for status URI: #{parent_status_uri}" } if replies_uri.nil?
    replies_uri
  end
end
