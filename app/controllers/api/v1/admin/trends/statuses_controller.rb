# frozen_string_literal: true

class Api::V1::Admin::Trends::StatusesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }
  before_action :set_statuses

  after_action :verify_authorized

  def index
    authorize :dashboard, :index?
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  private

  def set_statuses
    @statuses = cache_collection(Trends.statuses.query.limit(limit_param(DEFAULT_STATUSES_LIMIT)), Status)
  end
end
