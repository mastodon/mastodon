# frozen_string_literal: true

class Api::V1::Accounts::RelationshipsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @accounts = Account.where(id: account_ids).select('id')
    @following = Account.following_map(account_ids, current_user.account_id)
    @followed_by = Account.followed_by_map(account_ids, current_user.account_id)
    @blocking = Account.blocking_map(account_ids, current_user.account_id)
    @muting = Account.muting_map(account_ids, current_user.account_id)
    @requested = Account.requested_map(account_ids, current_user.account_id)
    @domain_blocking = Account.domain_blocking_map(account_ids, current_user.account_id)
  end

  private

  def account_ids
    @_account_ids ||= Array(params[:id]).map(&:to_i)
  end
end
