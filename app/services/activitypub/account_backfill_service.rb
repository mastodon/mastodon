# frozen_string_literal: true

class ActivityPub::AccountBackfillService < BaseService
  include JsonLdHelper

  MAX_STATUSES = (ENV['FETCH_REPLIES_MAX_SINGLE'] || 100).to_i

  def call(account, prefetched_body: nil, request_id: nil)
    @account = account
    @prefetched_body = prefetched_body
    @json = account_json
    return if account_outbox_uri.nil?

    @items = collection_items(account_outbox_uri, MAX_STATUSES)

    return if @items.nil?

    FetchReplyWorker.push_bulk(@items) { |reply_uri| [reply_uri, { 'request_id' => request_id }] }

    @items
  end

  def account_json
    begin
      if @prefetched_body.nil?
        fetch_resource(@account.uri, true)
      else
        body_to_json(@prefetched_body, compare_id: @account.uri)
      end
    rescue Oj::ParseError
      raise Error, "Error parsing JSON-LD document #{@account.uri}"
    end
  end

  def account_outbox_uri
    @json.fetch(:outbox, nil)
  end
end
