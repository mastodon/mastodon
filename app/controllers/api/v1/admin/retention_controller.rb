# frozen_string_literal: true

class Api::V1::Admin::RetentionController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :set_cohorts

  after_action :verify_authorized

  def create
    authorize :dashboard, :index?
    render json: @cohorts, each_serializer: REST::Admin::CohortSerializer
  end

  private

  def set_cohorts
    @cohorts = Admin::Metrics::Retention.new(
      params[:start_at],
      params[:end_at],
      params[:frequency]
    ).cohorts
  end
end
