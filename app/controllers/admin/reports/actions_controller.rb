# frozen_string_literal: true

class Admin::Reports::ActionsController < Admin::BaseController
  before_action :set_report

  def preview
    authorize @report, :show?
    @moderation_action = action_from_button
  end

  def create
    authorize @report, :show?

    case action_from_button
    when 'delete', 'mark_as_sensitive'
      Admin::StatusBatchAction.new(status_batch_action_params).save!
    when 'silence', 'suspend'
      Admin::AccountAction.new(account_action_params).save!
    else
      return redirect_to admin_report_path(@report), alert: I18n.t('admin.reports.unknown_action_msg', action: action_from_button)
    end

    redirect_to admin_reports_path, notice: I18n.t('admin.reports.processed_msg', id: @report.id)
  end

  private

  def status_batch_action_params
    shared_params
      .merge(status_ids: @report.status_ids)
  end

  def account_action_params
    shared_params
      .merge(target_account: @report.target_account)
  end

  def shared_params
    {
      current_account: current_account,
      report_id: @report.id,
      send_email_notification: !@report.spam?,
      text: params[:text],
      type: action_from_button,
    }
  end

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
    elsif params[:moderation_action]
      params[:moderation_action]
    end
  end
end
