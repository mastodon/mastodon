# frozen_string_literal: true

class Api::V1::Accounts::SearchController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def show
    @accounts = account_search

    render 'api/v1/accounts/index'
  end

  private

  def account_search
    AccountSearchService.new.call(
      params[:q],
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      resolving_search?,
      current_account
    )
  end

  def resolving_search?
    params[:resolve] == 'true'
  end
end
