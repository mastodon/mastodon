# frozen_string_literal: true

class Api::V1::BookmarksController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:bookmarks' }
  before_action :require_user!
  after_action :insert_pagination_headers

  def index
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_statuses
    preloaded_bookmarks
  end

  def preloaded_bookmarks
    preload_collection(results.map(&:status), Status)
  end

  def results
    @results ||= account_bookmarks.joins(:status).eager_load(:status).to_a_paginated_by_id(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def account_bookmarks
    current_account.bookmarks
  end

  def next_path
    api_v1_bookmarks_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_bookmarks_url pagination_params(min_id: pagination_since_id) unless results.empty?
  end

  def pagination_collection
    results
  end

  def records_continue?
    results.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end
end
