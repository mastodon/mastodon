# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    before_action :set_report, except: [:index]

    def index
      authorize :report, :index?

      # We previously only supported searching by target account domain for
      # reports, we now have more search options, but it's important that we
      # don't break any saved queries people may have:
      return redirect_to_new_filter if outdated_filter?

      # If there isn't a status filter parameter, redirect to include the status parameter as unresolved,
      # this ensures the "status" option menu always shows a highlighted option.
      if filter_params.exclude? :status
        if params.slice(*ReportFilter::DIRECT_KEYS).present?
          return redirect_to admin_reports_path(filter_params.merge({ status: 'all' }))
        else
          return redirect_to admin_reports_path(filter_params.merge({ status: 'unresolved' }))
        end
      end

      @reports = filtered_reports.page(params[:page])
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

    def filtered_reports
      ReportFilter.new(filter_params).results.order(id: :desc).includes(:account, :target_account)
    end

    def filter_params
      params.slice(*ReportFilter::KEYS).permit(*ReportFilter::KEYS)
    end

    def outdated_filter?
      params.include?(:by_target_domain) || params.include?(:resolved)
    end

    def redirect_to_new_filter
      by_target_domain = params.delete(:by_target_domain)
      resolved = params.delete(:resolved)

      redirect_to admin_reports_path filter_params.merge({
        search_type: 'target',
        search_term: by_target_domain,
        status: resolved == '1' ? 'resolved' : 'unresolved',
      })
    end

    def set_report
      @report = Report.find(params[:id])
    end
  end
end
