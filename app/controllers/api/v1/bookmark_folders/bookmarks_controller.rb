# frozen_string_literal: true

class Api::V1::BookmarkFolders::BookmarksController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:bookmarks' }
  before_action :require_user!
  after_action :insert_pagination_headers

  def index
    @folder = BookmarkFolder.where(account: current_account).find(params[:bookmark_folder_id])
    @bookmarks = load_bookmarks(@folder.bookmarks)

    render_bookmarks
  end

  def unfolded
    @bookmarks = load_bookmarks(current_account.bookmarks.where(folder_id: nil))

    render_bookmarks
  end

  private

  def load_bookmarks(scope)
    results = scope.joins(:status)
      .eager_load(:status)
      .to_a_paginated_by_id(limit_param(DEFAULT_STATUSES_LIMIT), params_slice(:max_id, :since_id, :min_id))

    preload_collection(results.map(&:status), Status)
  end

  def next_path
    folder_api_v1_bookmarks_url(@folder, pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    folder_api_v1_bookmarks_url(@folder, pagination_params(min_id: pagination_since_id)) unless @bookmarks.empty?
  end

  def render_bookmarks
    render json: @bookmarks,
           each_serializer: REST::StatusSerializer,
           relationships: StatusRelationshipsPresenter.new(@bookmarks, current_account.id)
  end

  def pagination_collection
    @bookmarks
  end

  def records_continue?
    @bookmarks.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end
end
