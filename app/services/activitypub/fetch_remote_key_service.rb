# frozen_string_literal: true

class ActivityPub::FetchRemoteKeyService < BaseService
  include JsonLdHelper

  class Error < StandardError; end

  # Returns actor that owns the key
  def call(uri, suppress_errors: true)
    raise Error, 'No key URI given' if uri.blank?

    @json = fetch_resource(uri, false)

    raise Error, "Unable to fetch key JSON at #{uri}" if @json.nil?
    raise Error, "Unsupported JSON-LD context for document #{uri}" unless supported_context?(@json)
    raise Error, "Unexpected object type for key #{uri}" unless expected_type?
    return find_actor(@json['id'], @json, suppress_errors) if actor_type?

    @owner = fetch_resource(owner_uri, true)

    raise Error, "Unable to fetch actor JSON #{owner_uri}" if @owner.nil?
    raise Error, "Unsupported JSON-LD context for document #{owner_uri}" unless supported_context?(@owner)
    raise Error, "Unexpected object type for actor #{owner_uri} (expected any of: #{SUPPORTED_TYPES})" unless expected_owner_type?
    raise Error, "publicKey id for #{owner_uri} does not correspond to #{@json['id']}" unless confirmed_owner?

    find_actor(owner_uri, @owner, suppress_errors)
  rescue Error => e
    Rails.logger.debug { "Fetching key #{uri} failed: #{e.message}" }
    raise unless suppress_errors
  end

  private

  def find_actor(uri, prefetched_body, suppress_errors)
    actor   = ActivityPub::TagManager.instance.uri_to_actor(uri)
    actor ||= ActivityPub::FetchRemoteActorService.new.call(uri, prefetched_body: prefetched_body, suppress_errors: suppress_errors)
    actor
  end

  def expected_type?
    actor_type? || public_key?
  end

  def actor_type?
    equals_or_includes_any?(@json['type'], ActivityPub::FetchRemoteActorService::SUPPORTED_TYPES)
  end

  def public_key?
    @json['publicKeyPem'].present? && @json['owner'].present?
  end

  def owner_uri
    @owner_uri ||= value_or_id(@json['owner'])
  end

  def expected_owner_type?
    equals_or_includes_any?(@owner['type'], ActivityPub::FetchRemoteActorService::SUPPORTED_TYPES)
  end

  def confirmed_owner?
    value_or_id(@owner['publicKey']) == @json['id']
  end
end
