# frozen_string_literal: true

class Api::V1::Accounts::RelationshipsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:follows' }
  before_action :require_user!

  def index
    accounts = load_accounts
    # .where doesn't guarantee that our results are in the same order
    # we requested them, so return the "right" order to the requestor.
    @accounts = accounts.index_by(&:id).values_at(*account_ids).compact
    render json: @accounts, each_serializer: REST::RelationshipSerializer, relationships: relationships
  end

  private

  def all_accounts
    Account.where(id: account_ids).select('id')
  end

  def unsuspended_accounts
    Account.without_suspended.where(id: account_ids).select('id')
  end

  def load_accounts
    if current_user.account.show_suspended?
      return all_accounts
    end
    unsuspended_accounts
  end

  def relationships
    AccountRelationshipsPresenter.new(@accounts, current_user.account_id)
  end

  def account_ids
    Array(params[:id]).map(&:to_i)
  end
end
