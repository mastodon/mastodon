# frozen_string_literal: true

class ActivityPub::FetchRemotePollService < BaseService
  include JsonLdHelper

  def call(poll, on_behalf_of = nil)
    @json = fetch_resource(poll.status.uri, true, on_behalf_of)

    return unless supported_context? && expected_type?

    expires_at = begin
      if @json['closed'].is_a?(String)
        @json['closed']
      elsif !@json['closed'].nil? && !@json['closed'].is_a?(FalseClass)
        Time.now.utc
      else
        @json['endTime']
      end
    end

    items = begin
      if @json['anyOf'].is_a?(Array)
        @json['anyOf']
      else
        @json['oneOf']
      end
    end

    latest_options = items.map { |item| item['name'].presence || item['content'] }

    # If for some reasons the options were changed, it invalidates all previous
    # votes, so we need to remove them
    poll.votes.delete_all if latest_options != poll.options

    poll.update!(
      last_fetched_at: Time.now.utc,
      expires_at: expires_at,
      options: latest_options,
      cached_tallies: items.map { |item| item.dig('replies', 'totalItems') || 0 }
    )
  end

  private

  def supported_context?
    super(@json)
  end

  def expected_type?
    equals_or_includes_any?(@json['type'], %w(Question))
  end
end
