# frozen_string_literal: true

class Api::V1::Trends::LinksController < Api::BaseController
  before_action :set_links

  def index
    render json: @links, each_serializer: REST::Trends::LinkSerializer
  end

  private

  def set_links
    @links = begin
      if Setting.trending_links
        Trends.links.get(true, limit_param(10))
      else
        []
      end
    end
  end
end
