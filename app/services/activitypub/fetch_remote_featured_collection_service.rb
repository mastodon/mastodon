# frozen_string_literal: true

class ActivityPub::FetchRemoteFeaturedCollectionService < BaseService
  include JsonLdHelper

  def call(uri, request_id: nil, prefetched_body: nil, on_behalf_of: nil)
    json = if prefetched_body.nil?
             fetch_resource(uri, true, on_behalf_of)
           else
             body_to_json(prefetched_body, compare_id: uri)
           end

    return unless supported_context?(json)
    return unless json['type'] == 'FeaturedCollection'

    # Fetching an unknown account should eventually also fetch its
    # collections, so it should be OK to only handle known accounts here
    account = Account.find_by(uri: json['attributedTo'])
    return unless account

    existing_collection = account.collections.find_by(uri:)
    return existing_collection if existing_collection.present?

    ActivityPub::ProcessFeaturedCollectionService.new.call(account, json, request_id:)
  end
end
