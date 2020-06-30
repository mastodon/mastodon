# frozen_string_literal: true

class Api::V1::Accounts::NotesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_account

  def create
    if params[:comment].blank?
      AccountNote.find_by(account: current_account, target_account: @account)&.destroy
    else
      @note = AccountNote.find_or_initialize_by(account: current_account, target_account: @account)
      @note.comment = params[:comment]
      @note.save! if @note.changed?
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
