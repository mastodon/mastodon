# frozen_string_literal: true

class Api::V1::Crypto::Keys::QueriesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :crypto }
  before_action :require_user!
  before_action :set_accounts
  before_action :set_query_results

  def create
    render json: @query_results, each_serializer: REST::Keys::QueryResultSerializer
  end

  private

  def set_accounts
    @accounts = Account.where(id: account_ids).includes(:devices)
  end

  def set_query_results
    @query_results = @accounts.filter_map { |account| ::Keys::QueryService.new.call(account) }
  end

  def account_ids
    Array(params[:id]).map(&:to_i)
  end
end
