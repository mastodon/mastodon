# frozen_string_literal: true

class ActivityPub::SynchronizeFollowersService < BaseService
  include JsonLdHelper
  include Payloadable

  MAX_COLLECTION_PAGES = 10

  def call(account, partial_collection_url)
    @account = account
    @expected_followers_ids = []

    return unless process_collection!(partial_collection_url)

    remove_unexpected_local_followers!
  end

  private

  def process_page!(items)
    page_expected_followers = extract_local_followers(items)
    @expected_followers_ids.concat(page_expected_followers.pluck(:id))

    handle_unexpected_outgoing_follows!(page_expected_followers)
  end

  def extract_local_followers(items)
    # There could be unresolved accounts (hence the call to .filter_map) but this
    # should never happen in practice, since in almost all cases we keep an
    # Account record, and should we not do that, we should have sent a Delete.
    # In any case there is not much we can do if that occurs.

    ActivityPub::TagManager.instance.uris_to_local_accounts(items)
  end

  def remove_unexpected_local_followers!
    @account.followers.local.where.not(id: @expected_followers_ids).reorder(nil).find_each do |unexpected_follower|
      UnfollowService.new.call(unexpected_follower, @account)
    end
  end

  def handle_unexpected_outgoing_follows!(expected_followers)
    expected_followers.each do |expected_follower|
      next if expected_follower.following?(@account)

      if expected_follower.requested?(@account)
        # For some reason the follow request went through but we missed it
        expected_follower.follow_requests.find_by(target_account: @account)&.authorize!
      else
        # Since we were not aware of the follow from our side, we do not have an
        # ID for it that we can include in the Undo activity. For this reason,
        # the Undo may not work with software that relies exclusively on
        # matching activity IDs and not the actor and target
        follow = Follow.new(account: expected_follower, target_account: @account)
        ActivityPub::DeliveryWorker.perform_async(build_undo_follow_json(follow), follow.account_id, follow.target_account.inbox_url)
      end
    end
  end

  def build_undo_follow_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::UndoFollowSerializer))
  end

  # Only returns true if the whole collection has been processed
  def process_collection!(collection_uri, max_pages: MAX_COLLECTION_PAGES)
    collection = fetch_collection(collection_uri)
    return false unless collection.is_a?(Hash)

    collection = fetch_collection(collection['first']) if collection['first'].present?

    while collection.is_a?(Hash)
      process_page!(as_array(collection_page_items(collection)))

      max_pages -= 1

      return true if collection['next'].blank? # We reached the end of the collection
      return false if max_pages <= 0 # We reached our pages limit

      collection = fetch_collection(collection['next'])
    end

    false
  end

  def collection_page_items(collection)
    case collection['type']
    when 'Collection', 'CollectionPage'
      collection['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      collection['orderedItems']
    end
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return if non_matching_uri_hosts?(@account.uri, collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, nil, raise_on_error: :temporary)
  end
end
