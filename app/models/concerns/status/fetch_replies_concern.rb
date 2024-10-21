# frozen_string_literal: true

module Status::FetchRepliesConcern
  extend ActiveSupport::Concern

  # enable/disable fetching all replies
  FETCH_REPLIES_ENABLED = ENV.key?('FETCH_REPLIES_ENABLED') ? ENV['FETCH_REPLIES_ENABLED'] == 'true' : true

  # debounce fetching all replies to minimize DoS
  FETCH_REPLIES_DEBOUNCE = (ENV['FETCH_REPLIES_DEBOUNCE'] || 15).to_i.minutes
  CREATED_RECENTLY_DEBOUNCE = (ENV['FETCH_REPLIES_CREATED_RECENTLY'] || 5).to_i.minutes

  included do
    scope :created_recently, -> { where(created_at: CREATED_RECENTLY_DEBOUNCE.ago..) }
    scope :not_created_recently, -> { where(created_at: ..CREATED_RECENTLY_DEBOUNCE.ago) }
    scope :fetched_recently, -> { where(fetched_replies_at: FETCH_REPLIES_DEBOUNCE.ago..) }
    scope :not_fetched_recently, -> { where(fetched_replies_at: ..FETCH_REPLIES_DEBOUNCE.ago).or(where(fetched_replies_at: nil)) }

    scope :shouldnt_fetch_replies, -> { local.merge(created_recently).merge(fetched_recently) }
    scope :should_fetch_replies, -> { local.invert_where.merge(not_created_recently).merge(not_fetched_recently) }
  end

  def should_fetch_replies?
    # we aren't brand new, and we haven't fetched replies since the debounce window
    FETCH_REPLIES_ENABLED && !local? && created_at <= CREATED_RECENTLY_DEBOUNCE.ago && (
      fetched_replies_at.nil? || fetched_replies_at <= FETCH_REPLIES_DEBOUNCE.ago
    )
  end
end
