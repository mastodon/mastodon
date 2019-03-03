# frozen_string_literal: true

class ActivityPub::FetchRemotePollService < BaseService
  include JsonLdHelper

  def call(poll, on_behalf_of = nil)
    @json = fetch_resource(poll.status.uri, true, on_behalf_of)

    return unless supported_context? && expected_type?

    expires_at = begin
      if @json['closed'].is_a?(String)
        @json['closed']
      elsif !@json['closed'].is_a?(FalseClass)
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

    poll.update!(
      expires_at: expires_at,
      cached_tallies: items.map { |item| item.dig('replies', 'totalItems') || 0 }
    )
  end

  private

  def supported_context?
    super(@json)
  end

  def expected_type?
    equals_or_includes_any?(@json['type'], 'Question')
  end
end
