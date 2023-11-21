# frozen_string_literal: true

class Api::V1::Accounts::RelationshipsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:follows' }
  before_action :require_user!

  def index
    scope = Account.where(id: account_ids).select('id')
    scope.merge!(Account.without_suspended) unless truthy_param?(:with_suspended)
    @accounts = scope.compact
    render json: @accounts, each_serializer: REST::RelationshipSerializer, relationships: relationships
  end

  private

  def relationships
    AccountRelationshipsPresenter.new(@accounts, current_user.account_id)
  end

  def account_ids
    Array(params[:id]).map(&:to_i).uniq
  end
end
