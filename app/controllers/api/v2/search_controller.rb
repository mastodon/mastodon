# frozen_string_literal: true

class Api::V2::SearchController < Api::V1::SearchController
  def index
    @search = Search.new(search_results)
    render json: @search, serializer: REST::V2::SearchSerializer
  end
end
