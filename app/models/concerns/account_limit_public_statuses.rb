# frozen_string_literal: true

module AccountLimitPublicStatuses
  extend ActiveSupport::Concern

  included do
    before_validation :limit_public_statuses
  end

  private

  def limit_public_statuses
    # ignore remote statuses, non-public statuses, and statuses with missing accounts
    return if account.nil? || account.domain.present? || visibility != 'public' || account.last_status_at.nil?
    return if (time_between_posts = ENV['SECONDS_BETWEEN_PUBLIC_POSTS'].to_i).zero?

    # get most recent public post from account
    last_public_status = account.statuses.with_public_visibility.recent.limit(1).first

    # if none, or from long enough ago, do nothing
    return if last_public_status.nil? || last_public_status.created_at + time_between_posts < Time.zone.now

    self.visibility = 'unlisted'
  end
end
