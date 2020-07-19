# frozen_string_literal: true

class Api::V1::CirclesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:circles' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:circles' }, except: [:index, :show]

  before_action :require_user!
  before_action :set_circle, except: [:index, :create]

  after_action :insert_pagination_headers, only: :index

  def index
    @circles = current_account.owned_circles.paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    render json: @circles, each_serializer: REST::CircleSerializer
  end

  def show
    render json: @circle, serializer: REST::CircleSerializer
  end

  def create
    @circle = current_account.owned_circles.create!(circle_params)
    render json: @circle, serializer: REST::CircleSerializer
  end

  def update
    @circle.update!(circle_params)
    render json: @circle, serializer: REST::CircleSerializer
  end

  def destroy
    @circle.destroy!
    render_empty
  end

  private

  def set_circle
    @circle = current_account.owned_circles.find(params[:id])
  end

  def circle_params
    params.permit(:title)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_circles_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_circles_url(pagination_params(since_id: pagination_since_id)) unless @circles.empty?
  end

  def pagination_max_id
    @circles.last.id
  end

  def pagination_since_id
    @circles.first.id
  end

  def records_continue?
    @circles.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
