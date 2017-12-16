# frozen_string_literal: true

module Admin
  class ReportedStatusesController < BaseController
    before_action :set_report
    before_action :set_status, only: [:update, :destroy]

    def create
      authorize :status, :update?

      @form         = Form::StatusBatch.new(form_status_batch_params.merge(current_account: current_account))
      flash[:alert] = I18n.t('admin.statuses.failed_to_execute') unless @form.save

      redirect_to admin_report_path(@report)
    end

    def update
      authorize @status, :update?
      @status.update!(status_params)
      log_action :update, @status
      redirect_to admin_report_path(@report)
    end

    def destroy
      authorize @status, :destroy?
      RemovalWorker.perform_async(@status.id)
      log_action :destroy, @status
      render json: @status
    end

    private

    def status_params
      params.require(:status).permit(:sensitive)
    end

    def form_status_batch_params
      params.require(:form_status_batch).permit(:action, status_ids: [])
    end

    def set_report
      @report = Report.find(params[:report_id])
    end

    def set_status
      @status = @report.statuses.find(params[:id])
    end
  end
end
