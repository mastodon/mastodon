# frozen_string_literal: true

class Api::V1::BookmarkFoldersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:bookmarks' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:bookmarks' }, except: [:index, :show]

  before_action :require_user!
  before_action :set_folder, except: [:index, :create]

  def index
    @folders = BookmarkFolder.where(account: current_account).all
    render json: @folders, each_serializer: REST::BookmarkFolderSerializer
  end

  def show
    render json: @folder, serializer: REST::BookmarkFolderSerializer
  end

  def create
    @folder = BookmarkFolder.create!(folder_params.merge(account: current_account))
    render json: @folder, serializer: REST::BookmarkFolderSerializer
  end

  def update
    @folder.update!(folder_params)
    render json: @folder, serializer: REST::BookmarkFolderSerializer
  end

  def destroy
    @folder.destroy!
    render_empty
  end

  private

  def set_folder
    @folder = BookmarkFolder.where(account: current_account).find(params[:id])
  end

  def folder_params
    params.permit(:title)
  end
end
