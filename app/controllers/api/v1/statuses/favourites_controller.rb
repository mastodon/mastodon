# frozen_string_literal: true

class Api::V1::Statuses::FavouritesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def create
    @status = favourited_status
    render 'api/v1/statuses/show'
  end

  def destroy
    @status = requested_status
    @favourites_map = { @status.id => false }

    UnfavouriteWorker.perform_async(current_user.account_id, @status.id)

    render 'api/v1/statuses/show'
  end

  private

  def favourited_status
    service_result.status.reload
  end

  def service_result
    FavouriteService.new.call(current_user.account, requested_status)
  end

  def requested_status
    Status.find(params[:status_id])
  end
end
