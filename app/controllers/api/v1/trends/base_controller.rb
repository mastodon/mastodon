# frozen_string_literal: true

class Api::V1::Trends::BaseController < Api::BaseController
  after_action :insert_pagination_headers

  private

  def enabled?
    Setting.trends
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
end
