# frozen_string_literal: true

class Api::V1::Admin::TrendsController < Api::BaseController
  before_action :require_staff!
  before_action :set_trends

  def index
    render json: @trends, each_serializer: REST::Admin::TagSerializer
  end

  private

  def set_trends
    @trends = TrendingTags.get(10, filtered: false)
  end
end
