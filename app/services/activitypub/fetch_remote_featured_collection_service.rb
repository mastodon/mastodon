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

    # A collection can be resolved on its own (e.g. through authorize_interaction)
    # before its account is known, so the account is fetched if necessary
    account = account_from_uri(value_or_id(first_of_value(json['attributedTo'])), request_id)
    return unless account

    existing_collection = account.collections.find_by(uri:)
    return existing_collection if existing_collection.present?

    ActivityPub::ProcessFeaturedCollectionService.new.call(account, json, request_id:)
  end

  private

  def account_from_uri(uri, request_id)
    account = ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
    account ||= ActivityPub::FetchRemoteAccountService.new.call(uri, request_id:)
    account
  end
end
