# frozen_string_literal: true

class Api::V1::ReportsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:reports' }, only: [:create]
  before_action :require_user!

  override_rate_limit_headers :create, family: :reports

  def create
    @report = ReportService.new.call(
      current_account,
      reported_account,
      report_params.merge(application: doorkeeper_token.application)
    )

    render json: @report, serializer: REST::ReportSerializer
  end

  private

  def reported_account
    Account.find(report_params[:account_id])
  end

  def report_params
    if Mastodon::Feature.collections_enabled?
      params.permit(:account_id, :comment, :category, :forward, forward_to_domains: [], status_ids: [], collection_ids: [], rule_ids: [])
    else
      params.permit(:account_id, :comment, :category, :forward, forward_to_domains: [], status_ids: [], rule_ids: [])
    end
  end
end
