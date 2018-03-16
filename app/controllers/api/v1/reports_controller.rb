# frozen_string_literal: true

class Api::V1::ReportsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:create]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  respond_to :json

  def index
    @reports = current_account.reports
    render json: @reports, each_serializer: REST::ReportSerializer
  end

  def create
    @report = ReportService.new.call(
      current_account,
      reported_account,
      status_ids: reported_status_ids,
      comment: report_params[:comment],
      forward: report_params[:forward]
    )

    render json: @report, serializer: REST::ReportSerializer
  end

  private

  def reported_status_ids
    Status.find(status_ids).pluck(:id)
  end

  def status_ids
    Array(report_params[:status_ids])
  end

  def reported_account
    Account.find(report_params[:account_id])
  end

  def report_params
    params.permit(:account_id, :comment, :forward, status_ids: [])
  end
end
