# frozen_string_literal: true

class ActivityPub::AccountBackfillService < BaseService
  include JsonLdHelper

  ENABLED = ENV['ACCOUNT_BACKFILL_ENABLED'].nil? || ENV['ACCOUNT_BACKFILL_ENABLED'] == 'true'
  MAX_STATUSES = (ENV['ACCOUNT_BACKFILL_MAX_STATUSES'] || 500).to_i
  MAX_PAGES = (ENV['ACCOUNT_BACKFILL_MAX_PAGES'] || 100).to_i

  def call(account, on_behalf_of: nil, request_id: nil)
    return unless ENABLED

    @account = account
    return if @account.nil? || @account.outbox_url.nil?

    @items, = collection_items(@account.outbox_url, max_items: MAX_STATUSES, max_pages: MAX_PAGES, on_behalf_of: on_behalf_of)
    @items = filter_items(@items)
    return if @items.nil?

    on_behalf_of_id = on_behalf_of&.id

    FetchReplyWorker.push_bulk(@items) do |status_uri_or_body|
      if status_uri_or_body.is_a?(Hash) && status_uri_or_body.key?('object') && status_uri_or_body.key?('id')
        # Re-add the minimally-acceptable @context, which gets stripped because this object comes inside a collection
        status_uri_or_body['@context'] = ActivityPub::TagManager::CONTEXT unless status_uri_or_body.key?('@context')
        [status_uri_or_body['id'], { prefetched_body: status_uri_or_body, request_id: request_id, on_behalf_of: on_behalf_of_id }]
      else
        [status_uri_or_body, { request_id: request_id, on_behalf_of: on_behalf_of_id }]
      end
    end

    @items
  end

  private

  # Reject any non-public statuses.
  # Since our request may have been signed on behalf of the follower,
  # we may have received followers-only statuses.
  #
  # Formally, a followers-only status is addressed to the account's followers collection.
  # We were not in that collection at the time that the post was made,
  # so followers-only statuses fetched by backfilling are not addressed to us.
  # Public and unlisted statuses are send to the activitystreams "Public" entity.
  # We are part of the public, so those posts *are* addressed to us.
  #
  # @param items [Array<Hash>]
  # @return [Array<Hash>]
  def filter_items(items)
    allowed = [:public, :unlisted]
    items.filter { |item| item.is_a?(String) || allowed.include?(ActivityPub::Parser::StatusParser.new(item).visibility) }
  end
end
