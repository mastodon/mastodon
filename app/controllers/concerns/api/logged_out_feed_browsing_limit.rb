# frozen_string_literal: true

# When the `limit_logged_out_feed_browsing` setting is enabled, logged-out
# visitors can see the first page of public feeds but need to log in to page
# through them. The most recent activity of the server stays visible to
# newcomers, while bulk scraping of its history requires an account.
module Api::LoggedOutFeedBrowsingLimit
  extend ActiveSupport::Concern

  PAGINATION_PARAMS = %i(max_id min_id offset).freeze

  included do
    # A distinct callback name, so it does not replace other `require_user!` callbacks
    before_action :require_user_for_feed_pagination!, if: :logged_out_feed_pagination?
  end

  private

  def logged_out_feed_browsing_limited?
    Setting.limit_logged_out_feed_browsing && current_user.nil?
  end

  def logged_out_feed_pagination?
    logged_out_feed_browsing_limited? && PAGINATION_PARAMS.any? { |key| params[key].present? }
  end

  def require_user_for_feed_pagination!
    require_user!
  end

  def insert_pagination_headers
    return if logged_out_feed_browsing_limited?

    super
  end
end
