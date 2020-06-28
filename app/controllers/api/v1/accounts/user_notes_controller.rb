# frozen_string_literal: true

class Api::V1::Accounts::UserNotesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_account

  def create
    if params[:comment].blank?
      UserNote.find_by(account: current_account, target_account: @account)&.destroy
    else
      @user_note = UserNote.find_or_initialize_by(account: current_account, target_account: @account)
      @user_note.comment = params[:comment]
      @user_note.save! if @user_note.changed?
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
