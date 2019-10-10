# frozen_string_literal: true

class Api::V1::Statuses::FavouritesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:favourites' }
  before_action :require_user!

  respond_to :json

  def create
    @status = favourited_status
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    @status = unfavourited_status
    @favourites_map = { @status.id => false }

    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_user&.account_id, favourites_map: @favourites_map)
  end

  private

  def favourited_status
    favourite_service_result.status.reload
  end

  def unfavourited_status
    unfavourite_service_result.status.reload
  end

  def favourite_service_result
    FavouriteService.new.call(current_user.account, requested_status)
  end

  def unfavourite_service_result
    UnfavouriteService.new.call(current_user.account, requested_status)
  end  

  def requested_status
    Status.find(params[:status_id])
  end
end
