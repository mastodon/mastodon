# frozen_string_literal: true

class ActivityPub::FetchRemoteStatusService < BaseService
  include JsonLdHelper

  # Should be called when uri has already been checked for locality
  def call(uri, prefetched_json = nil)
    @json = body_to_json(prefetched_json) || fetch_resource(uri)

    return unless supported_context?

    activity = activity_json
    actor_id = value_or_id(activity['actor'])

    return unless expected_type?(activity) && trustworthy_attribution?(uri, actor_id)

    actor = ActivityPub::TagManager.instance.uri_to_resource(actor_id, Account)
    actor = ActivityPub::FetchRemoteAccountService.new.call(actor_id) if actor.nil?

    return if actor.suspended?

    ActivityPub::Activity.factory(activity, actor).perform
  end

  private

  def activity_json
    if %w(Note Article).include? @json['type']
      {
        'type'   => 'Create',
        'actor'  => first_of_value(@json['attributedTo']),
        'object' => @json,
      }
    else
      @json
    end
  end

  def trustworthy_attribution?(uri, attributed_to)
    Addressable::URI.parse(uri).normalized_host.casecmp(Addressable::URI.parse(attributed_to).normalized_host).zero?
  end

  def supported_context?
    super(@json)
  end

  def expected_type?(json)
    %w(Create Announce).include? json['type']
  end
end
