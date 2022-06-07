# frozen_string_literal: true

class Admin::Reports::ActionsController < Admin::BaseController
  before_action :set_report

  def create
    authorize @report, :show?

    case action_from_button
    when 'delete', 'mark_as_sensitive'
      status_batch_action = Admin::StatusBatchAction.new(
        type: action_from_button,
        status_ids: @report.status_ids,
        current_account: current_account,
        report_id: @report.id,
        send_email_notification: !@report.spam?
      )

      status_batch_action.save!
    when 'silence', 'suspend'
      account_action = Admin::AccountAction.new(
        type: action_from_button,
        report_id: @report.id,
        target_account: @report.target_account,
        current_account: current_account,
        send_email_notification: !@report.spam?
      )

      account_action.save!
    end

    redirect_to admin_reports_path
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end

  def action_from_button
    if params[:delete]
      'delete'
    elsif params[:mark_as_sensitive]
      'mark_as_sensitive'
    elsif params[:silence]
      'silence'
    elsif params[:suspend]
      'suspend'
    end
  end
end
