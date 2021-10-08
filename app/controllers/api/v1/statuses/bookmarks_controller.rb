# frozen_string_literal: true

class Api::V1::Statuses::BookmarksController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:bookmarks' }
  before_action :require_user!
  before_action :set_status, only: [:create]

  def create
    current_account.bookmarks.find_or_create_by!(account: current_account, status: @status)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    bookmark = current_account.bookmarks.find_by(status_id: params[:status_id])

    if bookmark
      @status = bookmark.status
    else
      @status = Status.find(params[:status_id])
      authorize @status, :show?
    end

    bookmark&.destroy!

    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, bookmarks_map: { @status.id => false })
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
