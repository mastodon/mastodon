# frozen_string_literal: true

# TODO: can be removed after 5.0.0
class Admin::Reports::ActionsController < Admin::BaseController
  before_action :set_report
  before_action :set_account

  def preview
    authorize @target_account, :show?
    redirect_to preview_admin_account_moderation_action_path(account_id: @target_account.id)
  end

  def create
    authorize @target_account, :show?
    redirect_to new_admin_account_moderation_action_path(account_id: @target_account.id)
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end

  def set_account
    @target_account = @report.target_account
  end
end
