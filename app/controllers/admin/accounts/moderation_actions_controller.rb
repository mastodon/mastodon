# frozen_string_literal: true

class Admin::Accounts::ModerationActionsController < Admin::BaseController
  before_action :set_report
  before_action :set_account

  def new
    authorize @target_account, :show?

    @account_action  = Admin::AccountAction.new(type: get_param('type'), report_id: get_param('report_id'), send_email_notification: true, include_statuses: true)
    @warning_presets = AccountWarningPreset.all
  end

  def preview
    authorize @report, :show?

    @moderation_action = action_from_params
  end

  def create
    authorize @report, :show? if with_report?
    authorize @target_account, :show?

    @account_action = Admin::AccountAction.new(account_action_params)

    case action_from_params
    when 'delete', 'mark_as_sensitive'
      Admin::ModerationAction.new(shared_params).save!
    when 'silence', 'suspend', 'none', 'disable', 'sensitive'
      @account_action.save!
    else
      @warning_presets = AccountWarningPreset.all

      return render :new
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
      type: action_from_params,
      include_statuses: get_param('include_statuses'),
      warning_preset_id: get_param('warning_preset_id'),
      include_rule_violations: get_param('include_rule_violations'),
    }
  end

  def moderation_params
    {
      current_account: current_account,
      send_email_notification: !@report.spam?,
      report_id: @report.id,
      text: get_param('text'),
      type: action_from_params,
    }
  end

  def action_from_params
    params[:admin_account_action][:type] if params[:admin_account_action].is_a?(ActionController::Parameters) && params[:admin_account_action][:type]
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
