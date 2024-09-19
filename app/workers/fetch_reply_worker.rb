# frozen_string_literal: true

class FetchReplyWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(child_url, options = {})
    all_replies = options.delete('all_replies')

    status = FetchRemoteStatusService.new.call(child_url, **options.deep_symbolize_keys)

    # asked to fetch replies recursively - do the second-level calls async
    if all_replies && status
      json_status = fetch_resource(status.uri, true)

      collection = json_status['replies']
      unless collection.nil?
        # if expanding replies recursively, spread out the recursive calls
        ActivityPub::FetchRepliesWorker.perform_in(
          rand(1..30).seconds,
          status.id,
          collection,
          {
            allow_synchronous_requests: true,
            all_replies: true,
          }
        )
      end
    end
  end
end
