# frozen_string_literal: true

class Api::V1::Admin::Accounts::NotesController < Api::BaseController
  include Authorization
  include AccountableConcern

  PERMITTED_PARAMS = %i(
    content
  ).freeze

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:accounts' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:accounts' }, except: [:index, :show]
  before_action :set_account
  before_action :set_account_moderation_note, except: [:index, :create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    authorize @account, :show?
    render json: @account.targeted_moderation_notes.chronological.includes(:account), each_serializer: REST::Admin::ModerationNoteSerializer
  end

  def show
    authorize @account_moderation_note, :show?
    render json: @account_moderation_note, serializer: REST::Admin::ModerationNoteSerializer
  end

  def create
    authorize AccountModerationNote, :create?

    @account_moderation_note = current_account.account_moderation_notes.new(account_note_params.merge(target_account_id: @account.id))
    @account_moderation_note.save!

    render json: @account_moderation_note, serializer: REST::Admin::ModerationNoteSerializer
  end

  def destroy
    authorize @account_moderation_note, :destroy?
    @account_moderation_note.destroy!
    render_empty
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_account_moderation_note
    @account_moderation_note = AccountModerationNote.where(target_account_id: params[:account_id]).find(params[:id])
  end

  def account_note_params
    params
      .slice(*PERMITTED_PARAMS)
      .permit(*PERMITTED_PARAMS)
  end
end
