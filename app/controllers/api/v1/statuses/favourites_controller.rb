# frozen_string_literal: true

class Api::V1::Statuses::FavouritesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:favourites' }
  before_action :require_user!
  before_action :set_status

  def create
    FavouriteService.new.call(current_account, @status)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    UnfavouriteWorker.perform_async(current_account.id, @status.id)
    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, favourites_map: { @status.id => false })
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
