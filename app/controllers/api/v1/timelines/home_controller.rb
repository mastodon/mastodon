# frozen_string_literal: true

module Api::V1::Timelines
  class HomeController < BaseController
    before_action -> { doorkeeper_authorize! :read }, only: [:show]
    before_action :require_user!, only: [:show]

    def show
      @statuses = load_statuses
    end

    private

    def load_statuses
      cached_home_statuses.tap do |statuses|
        set_maps(statuses)
      end
    end

    def cached_home_statuses
      cache_collection home_statuses
    end

    def home_statuses
      account_home_feed.get(
        limit_param(DEFAULT_STATUSES_LIMIT),
        params[:max_id],
        params[:since_id]
      )
    end

    def account_home_feed
      Feed.new(:home, current_account)
    end

    def next_path
      api_v1_timelines_home_url pagination_params(max_id: @statuses.last.id)
    end

    def prev_path
      api_v1_timelines_home_url pagination_params(since_id: @statuses.first.id)
    end
  end
end
