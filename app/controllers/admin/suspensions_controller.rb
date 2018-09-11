# frozen_string_literal: true

module Admin
  class SuspensionsController < BaseController
    before_action :set_account

    def new
      @suspension = Form::AdminSuspensionConfirmation.new(report_id: params[:report_id])
    end

    def create
      authorize @account, :suspend?

      @suspension = Form::AdminSuspensionConfirmation.new(suspension_params)

      if suspension_params[:acct] == @account.acct
        resolve_report! if suspension_params[:report_id].present?
        perform_suspend!
        mark_reports_resolved!
        redirect_to admin_accounts_path
      else
        flash.now[:alert] = I18n.t('admin.suspensions.bad_acct_msg')
        render :new
      end
    end

    def destroy
      authorize @account, :unsuspend?
      @account.unsuspend!
      log_action :unsuspend, @account
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def suspension_params
      params.require(:form_admin_suspension_confirmation).permit(:acct, :report_id)
    end

    def resolve_report!
      report = Report.find(suspension_params[:report_id])
      report.resolve!(current_account)
      log_action :resolve, report
    end

    def perform_suspend!
      @account.suspend!
      Admin::SuspensionWorker.perform_async(@account.id)
      log_action :suspend, @account
    end

    def mark_reports_resolved!
      Report.where(target_account: @account).unresolved.update_all(action_taken: true, action_taken_by_account_id: current_account.id)
    end
  end
end
