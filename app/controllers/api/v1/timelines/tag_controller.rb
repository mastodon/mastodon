# frozen_string_literal: true

class Api::V1::Timelines::TagController < Api::BaseController
  before_action :load_tag
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  respond_to :json

  def show
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_tag
    @tag = Tag.find_by(name: params[:id].downcase)
  end

  def load_statuses
    cached_tagged_statuses
  end

  def cached_tagged_statuses
    cache_collection tagged_statuses, Status
  end

  def tagged_statuses
    if @tag.nil?
      []
    else
      tag_timeline_statuses.paginate_by_max_id(
        limit_param(DEFAULT_STATUSES_LIMIT),
        params[:max_id],
        params[:since_id]
      )
    end
  end

  def tag_timeline_statuses
    Status.as_tag_timeline(@tag, current_account, params[:local])
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.permit(:local, :limit).merge(core_params)
  end

  def next_path
    api_v1_timelines_tag_url params[:id], pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_tag_url params[:id], pagination_params(since_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
