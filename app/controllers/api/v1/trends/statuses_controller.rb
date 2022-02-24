# frozen_string_literal: true

class Api::V1::Trends::StatusesController < Api::BaseController
  before_action :set_statuses

  def index
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  private

  def set_statuses
    @statuses = begin
      if Setting.trends
        cache_collection(statuses_from_trends, Status)
      else
        []
      end
    end
  end

  def statuses_from_trends
    scope = Trends.statuses.query.allowed.in_locale(content_locale)
    scope = scope.filtered_for(current_account) if user_signed_in?
    scope.limit(limit_param(DEFAULT_STATUSES_LIMIT))
  end
end
