# frozen_string_literal: true

class ActivityPub::QuoteRequestWorker < ActivityPub::RawDistributionWorker
  def perform(quote_id)
    @quote = Quote.find(quote_id)
    @account = @quote.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= [@quote.quoted_account&.inbox_url].compact
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@quote, ActivityPub::QuoteRequestSerializer, signer: @account, allow_post_inlining: true))
  end
end
