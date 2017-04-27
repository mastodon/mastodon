# frozen_string_literal: true

class Api::V1::ReportsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:create]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  respond_to :json

  def index
    @reports = Report.where(account: current_account)
  end

  def create
    status_ids = report_params[:status_ids].is_a?(Enumerable) ? report_params[:status_ids] : [report_params[:status_ids]]

    @report = Report.create!(account: current_account,
                             target_account: Account.find(report_params[:account_id]),
                             status_ids: Status.find(status_ids).pluck(:id),
                             comment: report_params[:comment])

    render :show
  end

  private

  def report_params
    params.permit(:account_id, :comment, status_ids: [])
  end
end
