# frozen_string_literal: true

class ActivityPub::AccountBackfillService < BaseService
  include JsonLdHelper

  MAX_STATUSES = (ENV['ACCOUNT_BACKFILL_MAX_STATUSES'] || 500).to_i

  def call(account, request_id: nil)
    @account = account
    return if @account.nil? || @account.outbox_url.nil?

    @items = collection_items(@account.outbox_url, MAX_STATUSES)
    return if @items.nil?

    FetchReplyWorker.push_bulk(@items) do |status_uri_or_body|
      if status_uri_or_body.is_a?(Hash) && status_uri_or_body.key?('object') && status_uri_or_body.key?('id')
        # Re-add the minimally-acceptable @context, which gets stripped because this object comes inside a collection
        status_uri_or_body['@context'] = ActivityPub::TagManager::CONTEXT unless status_uri_or_body.key?('@context')
        [status_uri_or_body['id'], { prefetched_body: status_uri_or_body, request_id: request_id, on_behalf_of: @account.id }]
      else
        [status_uri_or_body, { request_id: request_id, on_behalf_of: @account.id }]
      end
    end

    @items
  end
end
