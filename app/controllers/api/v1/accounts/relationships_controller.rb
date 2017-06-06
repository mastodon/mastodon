# frozen_string_literal: true

class Api::V1::Accounts::RelationshipsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @accounts = requested_accounts.select(:id)
    @relationship_map = RelationshipMap.new(account_ids, current_user.account)
  end

  private

  def requested_accounts
    Account.where(id: account_ids)
  end

  def account_ids
    @_account_ids ||= Array(params[:id]).map(&:to_i)
  end
end
