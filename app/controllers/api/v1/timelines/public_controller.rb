# frozen_string_literal: true

module Api::V1::Timelines
  class PublicController < BaseController
    def show
      @statuses = load_statuses
    end

    private

    def load_statuses
      cached_public_statuses.tap do |statuses|
        set_maps(statuses)
      end
    end

    def cached_public_statuses
      cache_collection public_statuses
    end

    def public_statuses
      public_timeline_statuses.paginate_by_max_id(
        limit_param(DEFAULT_STATUSES_LIMIT),
        params[:max_id],
        params[:since_id]
      )
    end

    def public_timeline_statuses
      Status.as_public_timeline(current_account, params[:local])
    end

    def next_path
      api_v1_timelines_public_url pagination_params(max_id: @statuses.last.id)
    end

    def prev_path
      api_v1_timelines_public_url pagination_params(since_id: @statuses.first.id)
    end
  end
end
