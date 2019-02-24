# frozen_string_literal: true

class ActivityPub::FetchRepliesService < BaseService
  include JsonLdHelper

  def call(parent_status, collection_or_uri)
    @account = parent_status.account

    @items = collection_items(collection_or_uri)

    if @items.nil?
      uri = value_or_id(collection_or_uri)
      return if invalid_origin?(uri)
      collection = fetch_resource_without_id_validation(uri)
      raise Mastodon::UnexpectedResponseError if collection.nil?
      @items = collection_items(collection)
      return if @items.nil?
    end

    FetchReplyWorker.push_bulk(filtered_replies)
  end

  private

  def collection_items(collection)
    return unless collection.is_a?(Hash)
    case collection['type']
    when 'Collection', 'CollectionPage'
      collection['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      collection['orderedItems']
    end
  end

  def filtered_replies
    # Only fetch replies to the same server as the original status to avoid
    # amplification attacks.

    # Also limit to 5 fetched replies to limit potential for DoS.
    @items.map { |item| value_or_id(item) }.reject { |uri| invalid_origin?(uri) }.take(5)
  end

  def invalid_origin?(url)
    return true if unsupported_uri_scheme?(url)

    needle   = Addressable::URI.parse(url).host
    haystack = Addressable::URI.parse(@account.uri).host

    !haystack.casecmp(needle).zero?
  end
end
