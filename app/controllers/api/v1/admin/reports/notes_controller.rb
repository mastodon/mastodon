# frozen_string_literal: true

class Api::V1::Admin::Reports::NotesController < Api::BaseController
  include Authorization
  include AccountableConcern

  PERMITTED_PARAMS = %i(
    content
  ).freeze

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:reports' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:reports' }, except: [:index, :show]
  before_action :set_report
  before_action :set_report_note, except: [:index, :create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    authorize @report, :show?
    render json: @report.notes.chronological.includes(:account), each_serializer: REST::Admin::ModerationNoteSerializer
  end

  def show
    authorize @report_note, :show?
    render json: @report_note, serializer: REST::Admin::ModerationNoteSerializer
  end

  def create
    authorize ReportNote, :create?
    authorize @report, :update? if truthy_param?(:resolve_report) || truthy_param?(:unresolve_report)

    @report_note = current_account.report_notes.new(report_note_params.merge(report_id: @report.id))

    if @report_note.save!
      if truthy_param?(:resolve_report)
        @report.resolve!(current_account)
        log_action :resolve, @report
      elsif truthy_param?(:unresolve_report)
        @report.unresolve!
        log_action :reopen, @report
      end

      render json: @report_note, serializer: REST::Admin::ModerationNoteSerializer
    end
  end

  def destroy
    authorize @report_note, :destroy?
    @report_note.destroy!
    render_empty
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end

  def set_report_note
    @report_note = ReportNote.where(report_id: params[:report_id]).find(params[:id])
  end

  def report_note_params
    params
      .slice(*PERMITTED_PARAMS)
      .permit(*PERMITTED_PARAMS)
  end
end
