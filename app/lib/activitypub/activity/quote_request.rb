# frozen_string_literal: true

class ActivityPub::Activity::QuoteRequest < ActivityPub::Activity
  include Payloadable

  def perform
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    quoted_status = status_from_uri(object_uri)
    return if quoted_status.nil? || !quoted_status.account.local? || !quoted_status.distributable? || quoted_status.reblog?

    if StatusPolicy.new(@account, quoted_status).quote?
      accept_quote_request!(quoted_status)
    else
      reject_quote_request!(quoted_status)
    end
  end

  private

  def accept_quote_request!(quoted_status)
    status = status_from_uri(instrument_uri)
    status ||= import_instrument(quoted_status)
    status ||= ActivityPub::FetchRemoteStatusService.new.call(instrument_uri, on_behalf_of: quoted_status.account, request_id: @options[:request_id])
    # TODO: raise if status is nil

    # Sanity check
    return unless status.quote.quoted_status == quoted_status && status.account == @account

    status.quote.ensure_quoted_access
    status.quote.update!(activity_uri: @json['id'])
    status.quote.accept!

    json = Oj.dump(serialize_payload(status.quote, ActivityPub::AcceptQuoteRequestSerializer))
    ActivityPub::DeliveryWorker.perform_async(json, quoted_status.account_id, @account.inbox_url)

    # Ensure the user is notified
    LocalNotificationWorker.perform_async(quoted_status.account_id, status.quote.id, 'Quote', 'quote')

    # Ensure local followers get to see the post updated with approval
    DistributionWorker.perform_async(status.id, { 'update' => true, 'skip_notifications' => true })
  end

  def import_instrument(quoted_status)
    return unless @json['instrument'].is_a?(Hash)

    # NOTE: Replacing the object's context by that of the parent activity is
    # not sound, but it's consistent with the rest of the codebase
    instrument = @json['instrument'].merge({ '@context' => @json['@context'] })
    return if non_matching_uri_hosts?(@account.uri, instrument['id'])

    ActivityPub::FetchRemoteStatusService.new.call(instrument['id'], prefetched_body: instrument, on_behalf_of: quoted_status.account, request_id: @options[:request_id])
  end

  def reject_quote_request!(quoted_status)
    quote = Quote.new(
      quoted_status: quoted_status,
      quoted_account: quoted_status.account,
      status: Status.new(account: @account, uri: instrument_uri),
      account: @account,
      activity_uri: @json['id']
    )
    json = Oj.dump(serialize_payload(quote, ActivityPub::RejectQuoteRequestSerializer))
    ActivityPub::DeliveryWorker.perform_async(json, quoted_status.account_id, @account.inbox_url)
  end

  def instrument_uri
    value_or_id(@json['instrument'])
  end
end
