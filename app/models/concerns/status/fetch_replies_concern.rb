# frozen_string_literal: true

module Status::FetchRepliesConcern
  extend ActiveSupport::Concern

  # debounce fetching all replies to minimize DoS
  FETCH_REPLIES_DEBOUNCE = 30.minutes

  CREATED_RECENTLY_DEBOUNCE = 10.minutes

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
    !local? && created_at <= 10.minutes.ago && (
      fetched_replies_at.nil? || fetched_replies_at <= FETCH_REPLIES_DEBOUNCE.ago
    )
  end
end
