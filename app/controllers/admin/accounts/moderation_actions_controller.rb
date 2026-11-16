# frozen_string_literal: true

class Admin::Accounts::ModerationActionsController < Admin::BaseController
  before_action :set_report
  before_action :set_account

  def new
    authorize @target_account, :show?

    @account = @target_account
    @account_action  = Admin::AccountAction.new(type: get_param('type'), report_id: get_param('report_id'), send_email_notification: true, include_statuses: true)
    @warning_presets = AccountWarningPreset.all
  end

  def preview
    authorize @report, :show?

    @moderation_action = action_from_button
  end

  def create
    authorize @report, :show? if with_report?
    authorize @target_account, :show?

    @account_action = Admin::AccountAction.new(account_action_params)
    @account_action.target_account  = @target_account
    @account_action.current_account = current_account
    @account = @target_account

    case action_from_button
    when 'delete', 'mark_as_sensitive'
      Admin::ModerationAction.new(moderation_action_params).save!
    when 'silence', 'suspend', 'none', 'disable', 'sensitive'
      Admin::AccountAction.new(account_action_params).save!
    else
      if with_report?
        return redirect_to admin_report_path(@report), alert: I18n.t('admin.reports.unknown_action_msg', action: action_from_button)
      else
        @warning_presets = AccountWarningPreset.all

        return render :new
      end
    end

    redirect_path_success
  end

  private

  def redirect_path_success
    if with_report?
      redirect_to admin_reports_path, notice: I18n.t('admin.reports.processed_msg', id: @report.id)
    else
      redirect_to admin_account_path(@target_account.id)
    end
  end

  def moderation_action_params
    if params[:admin_account_action].present?
      shared_params
    else
      moderation_params
    end
  end

  def account_action_params
    shared_params
      .merge(target_account: @target_account)
  end

  def shared_params
    {
      current_account: current_account,
      send_email_notification: get_param('send_email_notification'),
      report_id: get_param('report_id'),
      text: get_param('text'),
      type: action_from_button,
      include_statuses: get_param('include_statuses'),
      warning_preset_id: get_param('warning_preset_id'),
    }
  end

  def moderation_params
    {
      current_account: current_account,
      send_email_notification: !@report.spam?,
      report_id: @report.id,
      text: get_param('text'),
      type: action_from_button,
    }
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
    elsif params[:admin_account_action]
      params[:admin_account_action][:type] if params[:admin_account_action][:type]
    end
  end

  def get_param(param)
    if params['admin_account_action']
      params['admin_account_action'][param]
    else
      params[param]
    end
  end

  def set_account
    @target_account = Account.find(params[:account_id])
  end

  def set_report
    return unless with_report?

    @report = Report.find(report_id)
  end

  def report_id
    get_param('report_id')
  end

  def with_report?
    report_id.present?
  end
end
