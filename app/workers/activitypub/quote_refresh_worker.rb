# frozen_string_literal: true

class ActivityPub::QuoteRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 3, dead: false, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(quote_id)
    quote = Quote.find_by(id: quote_id)
    return if quote.nil? || quote.updated_at > Quote::BACKGROUND_REFRESH_INTERVAL.ago

    quote.touch
    ActivityPub::VerifyQuoteService.new.call(quote)
  end
end
