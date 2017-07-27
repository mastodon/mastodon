# frozen_string_literal: true

class Api::V1::Accounts::RelationshipsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @accounts = Account.where(id: account_ids).select('id')
    render json: @accounts, each_serializer: REST::RelationshipSerializer, relationships: relationships
  end

  private

  def relationships
    AccountRelationshipsPresenter.new(@accounts, current_user.account_id)
  end

  def account_ids
    @_account_ids ||= Array(params[:id]).map(&:to_i)
  end
end
