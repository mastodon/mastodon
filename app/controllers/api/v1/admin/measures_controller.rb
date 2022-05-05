# frozen_string_literal: true

class Api::V1::Admin::MeasuresController < Api::BaseController
  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :require_staff!
  before_action :set_measures

  def create
    render json: @measures, each_serializer: REST::Admin::MeasureSerializer
  end

  private

  def set_measures
    @measures = Admin::Metrics::Measure.retrieve(
      params[:keys],
      params[:start_at],
      params[:end_at],
      params
    )
  end
end
