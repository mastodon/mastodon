# frozen_string_literal: true

class Api::V1::Trends::BaseController < Api::BaseController
  after_action :insert_pagination_headers

  private

  def trends_enabled?
    Setting.trends
  end

  def record_collection_when_trends_enabled
    trends_enabled? ? offset_and_limited_collection : []
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def offset_param
    params[:offset].to_i
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def next_path_params
    pagination_params(offset: offset_param + default_records_limit_param)
  end

  def prev_path_params
    pagination_params(offset: offset_param - default_records_limit_param)
  end

  def default_records_limit_param
    limit_param(self.class::DEFAULT_RECORDS_LIMIT)
  end

  def records_continue?
    record_collection_when_trends_enabled.size == default_records_limit_param
  end

  def records_precede?
    offset_param > default_records_limit_param
  end
end
