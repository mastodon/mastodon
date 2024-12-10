# frozen_string_literal: true

class Api::V1::ListsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:index, :show]

  before_action :require_user!, except: [:show]
  before_action :set_list, except: [:index, :create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    @lists = List.where(account: current_account).all
    render json: @lists, each_serializer: REST::ListSerializer
  end

  def show
    authorize @list, :show?
    render json: @list, serializer: REST::ListSerializer
  end

  def create
    @list = List.create!(list_params.merge(account: current_account))
    render json: @list, serializer: REST::ListSerializer
  end

  def update
    authorize @list, :update?
    @list.update!(list_params)
    render json: @list, serializer: REST::ListSerializer
  end

  def destroy
    authorize @list, :destroy?
    @list.destroy!
    render_empty
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.permit(:title, :description, :type, :replies_policy, :exclusive)
  end
end
