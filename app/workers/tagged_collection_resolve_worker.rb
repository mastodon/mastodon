# frozen_string_literal: true

class TaggedCollectionResolveWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 7

  def perform(status_id, uri, options = {})
    status = Status.find_by(id: status_id)
    return if status.nil?

    collection = ActivityPub::TagManager.instance.uri_to_resource(uri, Collection)
    collection ||= ActivityPub::FetchRemoteFeaturedCollectionService.new.call(uri, request_id: options['request_id'])
    return if collection.nil?

    status.tagged_objects.upsert({ ap_type: 'FeaturedCollection', object_id: collection.id, object_type: 'Collection' }, unique_by: %w(status_id object_type object_id))
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    raise(e) unless response_error_unsalvageable?(response)
  end
end
