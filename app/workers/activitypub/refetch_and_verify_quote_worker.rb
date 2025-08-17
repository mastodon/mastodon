# frozen_string_literal: true

class ActivityPub::RefetchAndVerifyQuoteWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(quote_id, quoted_uri, options = {})
    quote = Quote.find(quote_id)
    ActivityPub::VerifyQuoteService.new.call(quote, fetchable_quoted_uri: quoted_uri, request_id: options[:request_id])
  rescue ActiveRecord::RecordNotFound
    # Do nothing
    true
  rescue Mastodon::UnexpectedResponseError => e
    raise e unless response_error_unsalvageable?(e.response)
  end
end
