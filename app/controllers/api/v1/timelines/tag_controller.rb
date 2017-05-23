# frozen_string_literal: true

module Api::V1::Timelines
  class TagController < BaseController
    before_action :load_tag

    def show
      @statuses = load_statuses
    end

    private

    def load_tag
      @tag = Tag.find_by(name: params[:id].downcase)
    end

    def load_statuses
      cached_tagged_statuses.tap do |statuses|
        set_maps(statuses)
      end
    end

    def cached_tagged_statuses
      cache_collection tagged_statuses
    end

    def tagged_statuses
      if @tag.nil?
        []
      else
        tag_timeline_statuses.paginate_by_max_id(
          limit_param(DEFAULT_STATUSES_LIMIT),
          params[:max_id],
          params[:since_id]
        )
      end
    end

    def tag_timeline_statuses
      Status.as_tag_timeline(@tag, current_account, params[:local])
    end

    def next_path
      api_v1_timelines_tag_url params[:id], pagination_params(max_id: @statuses.last.id)
    end

    def prev_path
      api_v1_timelines_tag_url params[:id], pagination_params(since_id: @statuses.first.id)
    end
  end
end
