# frozen_string_literal: true

class Api::V1::Accounts::UserNotesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_account

  def create
    if params[:comment].blank?
      UserNote.where(account: current_account, target_account: @account).destroy_all
    else
      @user_note = UserNote.create_with(comment: params[:comment]).find_or_create_by!(account: current_account, target_account: @account)
      @user_note.update!(comment: params[:comment]) if @user_note.comment != params[:comment]
    end
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships_presenter
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def relationships_presenter
    AccountRelationshipsPresenter.new([@account.id], current_user.account_id)
  end
end
