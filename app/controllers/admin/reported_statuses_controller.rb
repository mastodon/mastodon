# frozen_string_literal: true

module Admin
  class ReportedStatusesController < BaseController
    def destroy
      status = Status.find params[:id]

      RemovalWorker.perform_async(status.id)
      redirect_to admin_report_path(report)
    end

    private

    def report
      Report.find(params[:report_id])
    end
  end
end
