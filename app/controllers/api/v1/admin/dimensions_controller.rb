# frozen_string_literal: true

class Api::V1::Admin::DimensionsController < Api::BaseController
  protect_from_forgery with: :exception

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :require_staff!
  before_action :set_dimensions

  def create
    render json: @dimensions, each_serializer: REST::Admin::DimensionSerializer
  end

  private

  def set_dimensions
    @dimensions = Admin::Metrics::Dimension.retrieve(
      params[:keys],
      params[:start_at],
      params[:end_at],
      params[:limit],
      params
    )
  end
end
