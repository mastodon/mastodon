# frozen_string_literal: true

class ActivityPub::FetchRemoteActorService < BaseService
  include JsonLdHelper
  include DomainControlHelper

  class Error < StandardError; end

  SUPPORTED_TYPES = %w(Application Group Organization Person Service).freeze

  # Does a WebFinger roundtrip on each call, unless `only_key` is true
  def call(uri, prefetched_body: nil, break_on_redirect: false, only_key: false, suppress_errors: true, request_id: nil)
    return if domain_not_allowed?(uri)
    return ActivityPub::TagManager.instance.uri_to_actor(uri) if ActivityPub::TagManager.instance.local_uri?(uri)

    @json = begin
      if prefetched_body.nil?
        fetch_resource(uri, true, raise_on_error: :all)
      else
        body_to_json(prefetched_body, compare_id: uri)
      end
    rescue Mastodon::UnexpectedResponseError => e
      queue_deletion!(uri) if e.response.code == 410

      raise Error, "Error fetching actor JSON at #{uri} (HTTP #{e.response.code})"
    rescue JSON::ParserError
      raise Error, "Error parsing JSON-LD document #{uri}"
    end

    raise Error, "Error fetching actor JSON at #{uri}" if @json.nil?
    raise Error, "Unsupported JSON-LD context for document #{uri}" unless supported_context?
    raise Error, "Unexpected object type for actor #{uri} (expected any of: #{SUPPORTED_TYPES})" unless expected_type?
    raise Error, "Actor #{uri} has moved to #{@json['movedTo']}" if break_on_redirect && @json['movedTo'].present?
    raise Error, "Actor #{uri} has neither 'preferredUsername' nor `webfinger`, which is a requirement for Mastodon compatibility" if @json['preferredUsername'].blank? && @json['webfinger'].blank?

    @uri = @json['id']

    ActivityPub::ProcessAccountService.new.call(@json, only_key:, request_id:, suppress_errors:)
  rescue Error, ActivityPub::ProcessAccountService::Error => e
    Rails.logger.debug { "Fetching actor #{uri} failed: #{e.message}" }
    raise unless suppress_errors
  end

  private

  def queue_deletion!(uri)
    account = Account.find_by(uri:)
    return unless account&.remote?

    Rails.logger.debug { "Deleting actor #{uri} because of HTTP 410 response" }

    account.suspend!(origin: :remote)
    AccountDeletionWorker.perform_async(account.id, { 'reserve_username' => false, 'skip_activitypub' => true })
  end

  def supported_context?
    super(@json)
  end

  def expected_type?
    equals_or_includes_any?(@json['type'], SUPPORTED_TYPES)
  end
end
