# frozen_string_literal: true

# Fetch all replies to a status, querying recursively through
# ActivityPub replies collections, fetching any statuses that
# we either don't already have or we haven't checked for new replies
# in the Status::FETCH_REPLIES_DEBOUNCE interval
class ActivityPub::FetchAllRepliesWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  # Global max replies to fetch per request
  MAX_REPLIES = 1000

  def perform(parent_status_id, current_account_id = nil, options = {})
    @parent_status = Status.find(parent_status_id)
    @current_account_id = current_account_id
    @current_account = @current_account_id.nil? ? nil : Account.find(@current_account_id)
    Rails.logger.debug { "FetchAllRepliesWorker - #{parent_status_id}: Fetching all replies for status: #{@parent_status}" }

    all_replies = get_replies(@parent_status.uri, options)
    got_replies = all_replies.length
    until all_replies.empty? || got_replies >= MAX_REPLIES
      next_reply = all_replies.pop
      next if next_reply.nil?

      new_replies = get_replies(next_reply, options)
      next if new_replies.nil?

      got_replies += new_replies.length
      all_replies.concat(new_replies)
    end

    Rails.logger.debug { "FetchAllRepliesWorker - #{parent_status_id}: fetched #{got_replies} replies" }
    got_replies
  end

  private

  def get_replies(status_uri, options = {})
    replies_uri = get_replies_uri(status_uri)
    return if replies_uri.nil?

    ActivityPub::FetchAllRepliesService.new.call(replies_uri, **options.deep_symbolize_keys)
  end

  def get_replies_uri(parent_status_uri)
    begin
      json_status = fetch_resource(parent_status_uri, true, @current_account)
      replies_uri = json_status['replies']
      Rails.logger.debug { "FetchAllRepliesWorker - #{@parent_status_id}: replies URI was nil" } if replies_uri.nil?
      replies_uri
    rescue => e
      Rails.logger.error { "FetchAllRepliesWorker - #{@parent_status_id}: Got exception while resolving replies URI: #{e} - #{e.message}" }
      nil
    end
  end
end
