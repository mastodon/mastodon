# frozen_string_literal: true

class Api::V1::Statuses::FavouritesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:favourites' }
  before_action :require_user!
  before_action :set_status, only: [:create]

  def create
    FavouriteService.new.call(current_account, @status)
	return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer, source_requested: return_source
  end

  def destroy
    fav = current_account.favourites.find_by(status_id: params[:status_id])

    if fav
      @status = fav.status
      UnfavouriteWorker.perform_async(current_account.id, @status.id)
    else
      @status = Status.find(params[:status_id])
      authorize @status, :show?
    end

    return_source = params[:format] == "source" ? true : false
    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, favourites_map: { @status.id => false }), source_requested: return_source
  rescue Mastodon::NotPermittedError
    not_found
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
