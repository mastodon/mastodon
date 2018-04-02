# frozen_string_literal: true

module Admin
  class ReportNotesController < BaseController
    before_action :set_report_note, only: [:destroy]

    def create
      authorize ReportNote, :create?

      @report_note = current_account.report_notes.new(resource_params)

      if @report_note.save
        redirect_to admin_report_path(@report_note.report_id), notice: I18n.t('admin.report_notes.created_msg')
      else
        @report       = @report_note.report
        @report_notes = @report.notes.latest
        @form = Form::StatusBatch.new

        render template: 'admin/reports/show'
      end
    end

    def destroy
      authorize @report_note, :destroy?
      @report_note.destroy!
      redirect_to admin_report_path(@report_note.report_id), notice: I18n.t('admin.report_notes.destroyed_msg')
    end

    private

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
