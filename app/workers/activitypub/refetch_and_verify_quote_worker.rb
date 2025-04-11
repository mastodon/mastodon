# frozen_string_literal: true

class ActivityPub::RefetchAndVerifyQuoteWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 3

  def perform(quote_id, quoted_uri)
    quote = Quote.find(quote_id)
    ActivityPub::VerifyQuoteService.new.call(quote, fetchable_quoted_uri: quoted_uri)
  rescue ActiveRecord::RecordNotFound
    # Do nothing
    true
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    if response_error_unsalvageable?(response)
      # Give up
    else
      raise e
    end
  end
end
