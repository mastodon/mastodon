# frozen_string_literal: true

class Api::V1::Admin::ActionLogsController < Api::BaseController
  include Authorization

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:audit_logs' }
  before_action :set_action_logs

  after_action :verify_authorized
  after_action :insert_pagination_headers

  PAGINATION_PARAMS = %i(limit).freeze

  def index
    authorize :audit_log, :index?
    render json: @action_logs, each_serializer: REST::Admin::ActionLogSerializer
  end

  private

  def set_action_logs
    @action_logs = filtered_action_logs.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def filtered_action_logs
    Admin::ActionLogFilter.new(filter_params).results
  end

  def filter_params
    # Rails uses the param name `action` internally, so we have to get it from the request.
    params_slice(*Admin::ActionLogFilter::API_KEYS)
      .merge(request.query_parameters.slice(:action))
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_audit_logs_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_audit_logs_url(pagination_params(min_id: pagination_since_id)) unless @action_logs.empty?
  end

  def pagination_max_id
    @action_logs.last.id
  end

  def pagination_since_id
    @action_logs.first.id
  end

  def records_continue?
    @action_logs.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params_slice(*PAGINATION_PARAMS).merge(core_params)
  end
end
