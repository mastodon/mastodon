# frozen_string_literal: true

class Admin::Reports::ActionsController < Admin::BaseController
  before_action :set_report
  before_action :verify_report_permissions
  before_action :unknown_action, unless: :valid_button_action?, only: :create

  STATUS_ACTIONS = %w(
    delete
    mark_as_sensitive
  ).freeze

  ACCOUNT_ACTIONS = %w(
    silence
    suspend
  ).freeze

  def preview
    @moderation_action = action_from_button
  end

  def create
    case action_from_button
    when *STATUS_ACTIONS
      Admin::StatusBatchAction.new(status_batch_action_params).save!
    when *ACCOUNT_ACTIONS
      Admin::AccountAction.new(account_action_params).save!
    end

    redirect_to admin_reports_path, notice: I18n.t('admin.reports.processed_msg', id: @report.id)
  end

  private

  def verify_report_permissions
    authorize @report, :show?
  end

  def unknown_action
    redirect_to admin_report_path(@report), alert: t('admin.reports.unknown_action_msg', action: action_from_button)
  end

  def valid_button_action?
    [STATUS_ACTIONS, ACCOUNT_ACTIONS]
      .flatten
      .include?(action_from_button)
  end

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
