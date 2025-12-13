# frozen_string_literal: true

class Api::V1Alpha::AsyncRefreshesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  def show
    async_refresh = AsyncRefresh.find(params[:id])

    if async_refresh
      render json: async_refresh
    else
      not_found
    end
  end
end
