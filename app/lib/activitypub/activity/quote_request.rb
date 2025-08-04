# frozen_string_literal: true

class ActivityPub::Activity::QuoteRequest < ActivityPub::Activity
  include Payloadable

  def perform
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    quoted_status = status_from_uri(object_uri)
    return if quoted_status.nil? || !quoted_status.account.local? || !quoted_status.distributable?

    if Mastodon::Feature.outgoing_quotes_enabled? && StatusPolicy.new(@account, quoted_status).quote?
      accept_quote_request!(quoted_status)
    else
      reject_quote_request!(quoted_status)
    end
  end

  private

  def accept_quote_request!(quoted_status)
    status = status_from_uri(@json['instrument'])
    # TODO: import inlined quote post if possible
    status ||= ActivityPub::FetchRemoteStatusService.new.call(@json['instrument'], on_behalf_of: @account.followers.local.first, request_id: @options[:request_id])
    # TODO: raise if status is nil

    # Sanity check
    return unless status.quote.quoted_status == quoted_status

    status.quote.ensure_quoted_access
    status.quote.update!(activity_uri: @json['id'])
    status.quote.accept!

    json = Oj.dump(serialize_payload(status.quote, ActivityPub::AcceptQuoteRequestSerializer))
    ActivityPub::DeliveryWorker.perform_async(json, quoted_status.account_id, @account.inbox_url)
  end

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
