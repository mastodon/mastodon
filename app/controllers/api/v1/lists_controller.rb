# frozen_string_literal: true

class Api::V1::ListsController < Api::BaseController
  LISTS_LIMIT = 50

  before_action -> { doorkeeper_authorize! :read },    only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write }, except: [:index, :show]

  before_action :require_user!
  before_action :set_list, except: [:index, :create]

  after_action :insert_pagination_headers, only: :index

  def index
    @lists = List.where(account: current_account).paginate_by_max_id(limit_param(LISTS_LIMIT), params[:max_id], params[:since_id])
    render json: @lists, each_serializer: REST::ListSerializer
  end

  def show
    render json: @list, serializer: REST::ListSerializer
  end

  def create
    @list = List.create!(list_params.merge(account: current_account))
    render json: @list, serializer: REST::ListSerializer
  end

  def update
    @list.update!(list_params)
    render json: @list, serializer: REST::ListSerializer
  end

  def destroy
    @list.destroy!
    render_empty
  end

  private

  def set_list
    @list = List.where(account: current_account).find(params[:id])
  end

  def list_params
    params.permit(:title)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_lists_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @lists.empty?
      api_v1_lists_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @lists.last.id
  end

  def pagination_since_id
    @lists.first.id
  end

  def records_continue?
    @lists.size == limit_param(LISTS_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
