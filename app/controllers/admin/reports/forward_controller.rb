# frozen_string_literal: true

class Admin::Reports::ForwardController < Admin::BaseController
  before_action :set_report

  def new
    authorize @report, :forward?
  end

  def create
    authorize @report, :forward?

    return redirect_back fallback_location: new_admin_report_forwarding_path(@report), flash: { error: I18n.t('admin.reports.forwarding.missing_domains') } if forward_params[:forwarded_to_domains].nil?

    ReportForwardingService.new.call(@report, current_account, {
      comment: forward_params[:comment],
      forward_to_domains: forward_params[:forwarded_to_domains],
    })

    redirect_to admin_report_path(@report), notice: I18n.t('admin.reports.forwarding.processed_msg', id: @report.id)
  end

  private

  def forward_params
    params.require(:report).permit(
      :comment,
      forwarded_to_domains: []
    )
  end

  def set_report
    @report = Report.find(params[:report_id])
  end
end
