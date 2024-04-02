# frozen_string_literal: true

class Api::V1::Trends::StatusesController < Api::BaseController
  vary_by 'Authorization, Accept-Language'

  before_action :set_statuses

  after_action :insert_pagination_headers

  def index
    cache_if_unauthenticated!
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  private

  def enabled?
    Setting.trends
  end

  def set_statuses
    @statuses = if enabled?
                  cache_collection(statuses_from_trends.offset(offset_param).limit(limit_param(DEFAULT_STATUSES_LIMIT)), Status)
                else
                  []
                end
  end

  def statuses_from_trends
    scope = Trends.statuses.query.allowed.in_locale(content_locale)
    scope = scope.filtered_for(current_account) if user_signed_in?
    scope
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def next_path
    api_v1_trends_statuses_url pagination_params(offset: offset_param + limit_param(DEFAULT_STATUSES_LIMIT)) if records_continue?
  end

  def prev_path
    api_v1_trends_statuses_url pagination_params(offset: offset_param - limit_param(DEFAULT_STATUSES_LIMIT)) if offset_param > limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def offset_param
    params[:offset].to_i
  end

  def records_continue?
    @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end
end
