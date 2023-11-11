# frozen_string_literal: true

class Api::V1::Trends::StatusesController < Api::V1::Trends::BaseController
  vary_by 'Authorization, Accept-Language'

  before_action :set_statuses

  DEFAULT_RECORDS_LIMIT = 20

  def index
    cache_if_unauthenticated!
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  private

  def set_statuses
    @statuses = if enabled?
                  cache_collection(statuses_from_trends.offset(offset_param).limit(default_records_limit_param), Status)
                else
                  []
                end
  end

  def statuses_from_trends
    scope = Trends.statuses.query.allowed.in_locale(content_locale)
    scope = scope.filtered_for(current_account) if user_signed_in?
    scope
  end

  def next_path
    api_v1_trends_statuses_url next_path_params if records_continue?
  end

  def prev_path
    api_v1_trends_statuses_url prev_path_params if records_precede?
  end

  def records_continue?
    @statuses.size == default_records_limit_param
  end
end
