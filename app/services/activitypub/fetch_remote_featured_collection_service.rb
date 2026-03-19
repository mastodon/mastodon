# frozen_string_literal: true

class ActivityPub::FetchRemoteFeaturedCollectionService < BaseService
  include JsonLdHelper

  def call(uri, on_behalf_of = nil)
    json = fetch_resource(uri, true, on_behalf_of)

    return unless supported_context?(json)
    return unless json['type'] == 'FeaturedCollection'

    # Fetching an unknown account should eventually also fetch its
    # collections, so it should be OK to only handle known accounts here
    account = Account.find_by(uri: json['attributedTo'])
    return unless account

    existing_collection = account.collections.find_by(uri:)
    return existing_collection if existing_collection.present?

    ActivityPub::ProcessFeaturedCollectionService.new.call(account, json)
  end
end
