# frozen_string_literal: true

class Api::V1::Accounts::SearchController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :require_user!

  def show
    @accounts = account_search
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def account_search
    AccountSearchService.new.call(
      params[:q],
      current_account,
      limit: limit_param(DEFAULT_ACCOUNTS_LIMIT),
      resolve: truthy_param?(:resolve),
      followers: truthy_param?(:followers),
      following: truthy_param?(:following),
      offset: params[:offset]
    )
  end
end
