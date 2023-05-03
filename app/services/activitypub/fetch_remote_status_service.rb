# frozen_string_literal: true

class ActivityPub::FetchRemoteStatusService < BaseService
  include JsonLdHelper
  include DomainControlHelper
  include Redisable

  DISCOVERIES_PER_REQUEST = 1000

  # Should be called when uri has already been checked for locality
  def call(uri, id: true, prefetched_body: nil, on_behalf_of: nil, expected_actor_uri: nil, request_id: nil)
    return if domain_not_allowed?(uri)

    @request_id = request_id || "#{Time.now.utc.to_i}-status-#{uri}"
    @json = if prefetched_body.nil?
              fetch_resource(uri, id, on_behalf_of)
            else
              body_to_json(prefetched_body, compare_id: id ? uri : nil)
            end

    return unless supported_context?

    actor_uri     = nil
    activity_json = nil
    object_uri    = nil

    if expected_object_type?
      actor_uri     = value_or_id(first_of_value(@json['attributedTo']))
      activity_json = { 'type' => 'Create', 'actor' => actor_uri, 'object' => @json }
      object_uri    = uri_from_bearcap(@json['id'])
    elsif expected_activity_type?
      actor_uri     = value_or_id(first_of_value(@json['actor']))
      activity_json = @json
      object_uri    = uri_from_bearcap(value_or_id(@json['object']))
    end

    return if activity_json.nil? || object_uri.nil? || !trustworthy_attribution?(@json['id'], actor_uri)
    return if expected_actor_uri.present? && actor_uri != expected_actor_uri
    return ActivityPub::TagManager.instance.uri_to_resource(object_uri, Status) if ActivityPub::TagManager.instance.local_uri?(object_uri)

    actor = account_from_uri(actor_uri)

    return if actor.nil? || actor.suspended?

    # If we fetched a status that already exists, then we need to treat the
    # activity as an update rather than create
    activity_json['type'] = 'Update' if equals_or_includes_any?(activity_json['type'], %w(Create)) && Status.where(uri: object_uri, account_id: actor.id).exists?

    with_redis do |redis|
      discoveries = redis.incr("status_discovery_per_request:#{@request_id}")
      redis.expire("status_discovery_per_request:#{@request_id}", 5.minutes.seconds)
      return nil if discoveries > DISCOVERIES_PER_REQUEST
    end

    ActivityPub::Activity.factory(activity_json, actor, request_id: @request_id).perform
  end

  private

  def trustworthy_attribution?(uri, attributed_to)
    return false if uri.nil? || attributed_to.nil?

    Addressable::URI.parse(uri).normalized_host.casecmp(Addressable::URI.parse(attributed_to).normalized_host).zero?
  end

  def account_from_uri(uri)
    actor = ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
    actor = ActivityPub::FetchRemoteAccountService.new.call(uri, id: true, request_id: @request_id) if actor.nil? || actor.possibly_stale?
    actor
  end

  def supported_context?
    super(@json)
  end

  def expected_activity_type?
    equals_or_includes_any?(@json['type'], %w(Create Announce))
  end

  def expected_object_type?
    equals_or_includes_any?(@json['type'], ActivityPub::Activity::Create::SUPPORTED_TYPES + ActivityPub::Activity::Create::CONVERTED_TYPES)
  end
end
