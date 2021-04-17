# frozen_string_literal: true

class Api::V1::Accounts::PinsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_account

  def create
    AccountPin.create!(account: current_account, target_account: @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships_presenter
  end

  def destroy
    pin = AccountPin.find_by(account: current_account, target_account: @account)
    pin&.destroy!
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
