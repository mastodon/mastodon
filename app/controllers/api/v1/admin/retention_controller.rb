# frozen_string_literal: true

class Api::V1::Admin::RetentionController < Api::BaseController
  protect_from_forgery with: :exception

  before_action :require_staff!
  before_action :set_cohorts

  def create
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
