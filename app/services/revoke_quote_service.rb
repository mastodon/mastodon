# frozen_string_literal: true

class RevokeQuoteService < BaseService
  include Payloadable

  def call(quote)
    @quote = quote
    @account = quote.quoted_account

    @quote.reject!
    distribute_stamp_deletion!
  end

  private

  def distribute_stamp_deletion!
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
    @signed_activity_json ||= Oj.dump(serialize_payload(@quote, ActivityPub::DeleteQuoteAuthorizationSerializer, signer: @account, always_sign: true))
  end
end
