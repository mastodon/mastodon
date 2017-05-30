# frozen_string_literal: true

module Api::V1::Timelines
  class BaseController < ApiController
    respond_to :json
    after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

    private

    def cache_collection(raw)
      super(raw, Status)
    end

    def pagination_params(core_params)
      params.permit(:local, :limit).merge(core_params)
    end

    def insert_pagination_headers
      set_pagination_headers(next_path, prev_path)
    end

    def next_path
      raise 'Override in child controllers'
    end

    def prev_path
      raise 'Override in child controllers'
    end
  end
end
