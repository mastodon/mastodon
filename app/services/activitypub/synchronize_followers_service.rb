# frozen_string_literal: true

class ActivityPub::SynchronizeFollowersService < BaseService
  include JsonLdHelper
  include Payloadable

  def call(account, partial_collection_url)
    @account = account

    items = collection_items(partial_collection_url)
    return if items.nil?

    @expected_followers = items.map { |uri| ActivityPub::TagManager.instance.uri_to_resource(uri, Account) }.compact
    # TODO: what to do with unresolvable accounts?

    remove_unexpected_local_followers!
    undo_unexpected_outgoing_follows!
  end

  private

  def remove_unexpected_local_followers!
    @account.followers.local.where.not(id: @expected_followers.map(&:id)).each do |unexpected_follower|
      UnfollowService.new.call(unexpected_follower, @account)
    end
  end

  def undo_unexpected_outgoing_follows!
    @expected_followers.each do |expected_follower|
      next if expected_follower.following?(@account)

      follow = Follow.new(account: expected_follower, target_account: @account)
      # TODO: the follow doesn't have an uri, how does that work?
      ActivityPub::DeliveryWorker.perform_async(build_undo_follow_json(follow), follow.account_id, follow.target_account.inbox_url)
    end
  end

  def build_undo_follow_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::UndoFollowSerializer))
  end

  def collection_items(collection_or_uri)
    collection = fetch_collection(collection_or_uri)
    return unless collection.is_a?(Hash)

    collection = fetch_collection(collection['first']) if collection['first'].present?
    return unless collection.is_a?(Hash)

    case collection['type']
    when 'Collection', 'CollectionPage'
      collection['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      collection['orderedItems']
    end
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return if invalid_origin?(collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, nil, true)
  end
end
