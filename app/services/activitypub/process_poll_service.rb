# frozen_string_literal: true

class ActivityPub::ProcessPollService < BaseService
  include JsonLdHelper

  def call(poll, json)
    @json = json

    return unless expected_type?

    previous_expires_at = poll.expires_at

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

    voters_count = @json['votersCount']

    latest_options = items.filter_map { |item| item['name'].presence || item['content'] }

    # If for some reasons the options were changed, it invalidates all previous
    # votes, so we need to remove them
    poll.votes.delete_all if latest_options != poll.options

    begin
      poll.update!(
        last_fetched_at: Time.now.utc,
        expires_at: expires_at,
        options: latest_options,
        cached_tallies: items.map { |item| item.dig('replies', 'totalItems') || 0 },
        voters_count: voters_count
      )
    rescue ActiveRecord::StaleObjectError
      poll.reload
      retry
    end

    # If the poll had no expiration date set but now has, and people have voted,
    # schedule a notification.
    if previous_expires_at.nil? && poll.expires_at.present? && poll.votes.exists?
      PollExpirationNotifyWorker.perform_at(poll.expires_at + 5.minutes, poll.id)
    end
  end

  private

  def expected_type?
    equals_or_includes_any?(@json['type'], %w(Question))
  end
end
