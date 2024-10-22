# frozen_string_literal: true

class ActivityPub::AccountBackfillService < BaseService
  include JsonLdHelper

  MAX_STATUSES = (ENV['ACCOUNT_BACKFILL_STATUSES'] || 100).to_i

  def call(account, request_id: nil)
    @account = account
    return if @account.nil? || @account.outbox_url.nil?

    @items = collection_items(@account.outbox_url, MAX_STATUSES)
    return if @items.nil?

    FetchReplyWorker.push_bulk(@items) do |status_uri_or_body|
      if status_uri_or_body&.fetch('type', '') == 'Note'
        [status_uri_or_body['id'], { 'prefetched_body' => status_uri_or_body, 'request_id' => request_id }]
      else
        [status_uri_or_body, { 'request_id' => request_id }]
      end
    end

    @items
  end
end
