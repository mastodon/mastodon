# frozen_string_literal: true

module Admin
  class AccountActionsController < BaseController
    before_action :set_account

    def new
      authorize @account, :show?

      @account_action  = Admin::AccountAction.new(type: params[:type], report_id: params[:report_id], send_email_notification: true, include_statuses: true)
      @warning_presets = AccountWarningPreset.all
    end

    def create
      authorize @account, :show?

      @account_action                 = Admin::AccountAction.new(resource_params)
      @account_action.target_account  = @account
      @account_action.current_account = current_account

      if @account_action.save
        if @account_action.with_report?
          redirect_to admin_reports_path, notice: I18n.t('admin.reports.processed_msg', id: resource_params[:report_id])
        else
          redirect_to admin_account_path(@account.id)
        end
      else
        @warning_presets = AccountWarningPreset.all

        render :new
      end
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def resource_params
      params
        .expect(admin_account_action: [:type, :report_id, :warning_preset_id, :text, :send_email_notification, :include_statuses])
    end
  end
end
