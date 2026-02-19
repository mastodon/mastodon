# frozen_string_literal: true

class RevokeQuoteService < BaseService
  include Payloadable

  def call(quote)
    @quote = quote
    @account = quote.quoted_account

    @quote.reject!
    distribute_update!
    distribute_stamp_deletion!
  end

  private

  def distribute_update!
    return if @quote.status_id.nil?

    DistributionWorker.perform_async(@quote.status_id, { 'update' => true })
  end

  def distribute_stamp_deletion!
    # It is possible the quoted status has been soft-deleted.
    # In this case, `signed_activity_json` would fail, but we can just ignore
    # that, as we have already federated deletion.
    return if @quote.quoted_status.nil?

    ActivityPub::DeliveryWorker.push_bulk(inboxes, limit: 1_000) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end
  end

  def inboxes
    [
      @quote.status,
      @quote.quoted_status,
    ].compact.map { |status| StatusReachFinder.new(status, unsafe: true).inboxes }.flatten.uniq
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@quote, ActivityPub::DeleteQuoteAuthorizationSerializer, signer: @account, always_sign: true, force_approval_id: true))
  end
end
