# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    before_action :set_report, except: [:index]

    def index
      authorize :report, :index?

      # We previously only supported searching reports by target account domain,
      # target account ID or account ID, we now have more search options, but
      # it's important that we don't break any saved queries people may have:
      return redirect_to_new_filter if reports_filter.outdated?

      @reports = filtered_reports.page(params[:page])
    rescue Mastodon::InvalidParameterError => e
      flash.now[:error] = e.message
      @reports = []
    end

    def show
      authorize @report, :show?

      @report_note  = @report.notes.new
      @report_notes = @report.notes.chronological.includes(:account)
      @action_logs  = @report.history.includes(:target)
      @form         = Admin::StatusBatchAction.new
      @statuses     = @report.statuses.with_includes
    end

    def assign_to_self
      authorize @report, :update?
      @report.update!(assigned_account_id: current_account.id)
      log_action :assigned_to_self, @report
      redirect_to admin_report_path(@report)
    end

    def unassign
      authorize @report, :update?
      @report.update!(assigned_account_id: nil)
      log_action :unassigned, @report
      redirect_to admin_report_path(@report)
    end

    def reopen
      authorize @report, :update?
      @report.unresolve!
      log_action :reopen, @report
      redirect_to admin_report_path(@report)
    end

    def resolve
      authorize @report, :update?
      @report.resolve!(current_account)
      log_action :resolve, @report
      redirect_to admin_reports_path, notice: I18n.t('admin.reports.resolved_msg')
    end

    private

    def reports_filter
      @reports_filter ||= ReportFilter.new(filter_params)
    end

    def filtered_reports
      reports_filter.results.order(id: :desc).includes(:account, :target_account)
    end

    def filter_params
      params.slice(*ReportFilter::ALL_KEYS).permit(*ReportFilter::ALL_KEYS)
    end

    def redirect_to_new_filter
      redirect_to admin_reports_path(reports_filter.updated_filter)
    end

    def set_report
      @report = Report.find(params[:id])
    end
  end
end
