# frozen_string_literal: true

class Api::V1::Admin::ReportsController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { doorkeeper_authorize! :'admin:read', :'admin:read:reports' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :'admin:write', :'admin:write:reports' }, except: [:index, :show]
  before_action :require_staff!
  before_action :set_reports, only: :index
  before_action :set_report, except: :index

  after_action :insert_pagination_headers, only: :index

  FILTER_PARAMS = %i(
    resolved
    account_id
    target_account_id
  ).freeze

  PAGINATION_PARAMS = (%i(limit) + FILTER_PARAMS).freeze

  def index
    authorize :report, :index?
    render json: @reports, each_serializer: REST::Admin::ReportSerializer
  end

  def show
    authorize @report, :show?
    render json: @report, serializer: REST::Admin::ReportSerializer
  end

  def assign_to_self
    authorize @report, :update?
    @report.update!(assigned_account_id: current_account.id)
    log_action :assigned_to_self, @report
    render json: @report, serializer: REST::Admin::ReportSerializer
  end

  def unassign
    authorize @report, :update?
    @report.update!(assigned_account_id: nil)
    log_action :unassigned, @report
    render json: @report, serializer: REST::Admin::ReportSerializer
  end

  def reopen
    authorize @report, :update?
    @report.unresolve!
    log_action :reopen, @report
    render json: @report, serializer: REST::Admin::ReportSerializer
  end

  def resolve
    authorize @report, :update?
    @report.resolve!(current_account)
    log_action :resolve, @report
    render json: @report, serializer: REST::Admin::ReportSerializer
  end

  private

  def set_reports
    @reports = filtered_reports.order(id: :desc).with_accounts.to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_report
    @report = Report.find(params[:id])
  end

  def filtered_reports
    ReportFilter.new(filter_params).results
  end

  def filter_params
    params.permit(*FILTER_PARAMS)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_reports_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_reports_url(pagination_params(min_id: pagination_since_id)) unless @reports.empty?
  end

  def pagination_max_id
    @reports.last.id
  end

  def pagination_since_id
    @reports.first.id
  end

  def records_continue?
    @reports.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
