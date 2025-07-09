# frozen_string_literal: true

class ActivityPub::Activity::QuoteRequest < ActivityPub::Activity
  include Payloadable

  def perform
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    quoted_status = status_from_uri(object_uri)
    return if quoted_status.nil? || !quoted_status.account.local? || !quoted_status.distributable?

    # For now, we don't support being quoted by external servers
    reject_quote_request!(quoted_status)
  end

  private

  def reject_quote_request!(quoted_status)
    quote = Quote.new(
      quoted_status: quoted_status,
      quoted_account: quoted_status.account,
      status: Status.new(account: @account, uri: @json['instrument']),
      account: @account,
      activity_uri: @json['id']
    )
    json = Oj.dump(serialize_payload(quote, ActivityPub::RejectQuoteRequestSerializer))
    ActivityPub::DeliveryWorker.perform_async(json, quoted_status.account_id, @account.inbox_url)
  end
end
