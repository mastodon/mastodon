# frozen_string_literal: true

module Api::V1::Timelines
  class SearchController < BaseController
    before_action :load_query

    def public
      @statuses = Status.as_public_timeline(current_account, params[:local]).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
      @statuses = cache_collection(@statuses)

      set_maps(@statuses)

      next_path = api_v1_public_timeline_url(pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
      prev_path = api_v1_public_timeline_url(pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

      set_pagination_headers(next_path, prev_path)

      render :index
    end


    def show
      @statuses = load_statuses
    end

    private

    def load_query
      @query = params['id']
    end

    def load_statuses
      cached_search_statuses.tap do |statuses|
        set_maps(statuses)
      end
    end

    def cached_search_statuses
      cache_collection search_statuses
    end

    def search_statuses
      if @query.nil?
        []
      else
        search_timeline_statuses.paginate_by_max_id(
          limit_param(DEFAULT_STATUSES_LIMIT),
          params[:max_id],
          params[:since_id]
        )
      end
    end

    def search_timeline_statuses
      Status.as_search_timeline(@query, current_account)
    end

    def next_path
      api_v1_timelines_search_url params[:id], pagination_params(max_id: @statuses.last.id)
    end

    def prev_path
      api_v1_timelines_search_url params[:id], pagination_params(since_id: @statuses.first.id)
    end
  end
end
