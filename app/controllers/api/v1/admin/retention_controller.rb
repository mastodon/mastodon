# frozen_string_literal: true

class Api::V1::Admin::RetentionController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :set_retention

  after_action :verify_authorized

  def create
    authorize :dashboard, :index?
    render json: @retention.cohorts, each_serializer: REST::Admin::CohortSerializer
  end

  private

  def set_retention
    @retention = Admin::Metrics::Retention.new(
      params.require(:start_at),
      params.require(:end_at),
      params[:frequency]
    )
  end
end
