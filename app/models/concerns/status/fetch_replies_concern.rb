# frozen_string_literal: true

module Status::FetchRepliesConcern
  extend ActiveSupport::Concern

  # debounce fetching all replies to minimize DoS
  # Period to wait between fetching replies
  FETCH_REPLIES_COOLDOWN_MINUTES = 15.minutes
  # Period to wait after a post is first created before fetching its replies
  FETCH_REPLIES_INITIAL_WAIT_MINUTES = 5.minutes

  included do
    scope :created_recently, -> { where(created_at: FETCH_REPLIES_INITIAL_WAIT_MINUTES.ago..) }
    scope :not_created_recently, -> { where(created_at: ..FETCH_REPLIES_INITIAL_WAIT_MINUTES.ago) }
    scope :fetched_recently, -> { where(fetched_replies_at: FETCH_REPLIES_COOLDOWN_MINUTES.ago..) }
    scope :not_fetched_recently, -> { where(fetched_replies_at: [nil, ..FETCH_REPLIES_COOLDOWN_MINUTES.ago]) }

    scope :should_not_fetch_replies, -> { local.or(created_recently.or(fetched_recently)) }
    scope :should_fetch_replies, -> { remote.not_created_recently.not_fetched_recently }

    # statuses for which we won't receive update or deletion actions,
    # and should update when fetching replies
    # Status from an account which either
    # a) has only remote followers
    # b) has local follows that were created after the last update time, or
    # c) has no known followers
    scope :unsubscribed, lambda {
      remote.merge(
        Status.left_outer_joins(account: :followers).where.not(followers_accounts: { domain: nil })
              .or(where.not('follows.created_at < statuses.updated_at'))
              .or(where(follows: { id: nil }))
      )
    }
  end

  def should_fetch_replies?
    # we aren't brand new, and we haven't fetched replies since the debounce window
    !local? && distributable? && created_at <= FETCH_REPLIES_INITIAL_WAIT_MINUTES.ago && (
      fetched_replies_at.nil? || fetched_replies_at <= FETCH_REPLIES_COOLDOWN_MINUTES.ago
    )
  end
end
