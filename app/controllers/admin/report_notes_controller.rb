# frozen_string_literal: true

module Admin
  class ReportNotesController < BaseController
    before_action :set_report_note, only: [:destroy]

    def create
      authorize :report_note, :create?

      @report_note = current_account.report_notes.new(resource_params)
      @report      = @report_note.report

      if @report_note.save
        if params[:create_and_resolve]
          @report.resolve!(current_account)
          log_action :resolve, @report
        elsif params[:create_and_unresolve]
          @report.unresolve!
          log_action :reopen, @report
        end

        User.those_who_can(:manage_reports).includes(:account).find_each do |u|
          # Prevent notifications to the author of the report note:
          next if @report_note.account.id == u.account.id

          LocalNotificationWorker.perform_async(u.account_id, @report_note.id, 'ReportNote', 'admin.report_note')
          AdminMailer.with(recipient: u.account).new_report_note(@report_note).deliver_later if u.allows_report_emails?
        end

        redirect_to after_create_redirect_path, notice: I18n.t('admin.report_notes.created_msg')
      else
        @report_notes = @report.notes.chronological.includes(:account)
        @action_logs  = @report.history.includes(:target)
        @form         = Admin::StatusBatchAction.new
        @statuses     = @report.statuses.with_includes

        render 'admin/reports/show'
      end
    end

    def destroy
      authorize @report_note, :destroy?
      @report_note.destroy!
      redirect_to admin_report_path(@report_note.report_id), notice: I18n.t('admin.report_notes.destroyed_msg')
    end

    private

    def after_create_redirect_path
      if params[:create_and_resolve]
        admin_reports_path
      else
        admin_report_path(@report)
      end
    end

    def resource_params
      params.require(:report_note).permit(
        :content,
        :report_id
      )
    end

    def set_report_note
      @report_note = ReportNote.find(params[:id])
    end
  end
end
