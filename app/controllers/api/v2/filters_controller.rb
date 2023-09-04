# frozen_string_literal: true

class Api::V2::FiltersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:filters' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:filters' }, except: [:index, :show]
  before_action :require_user!
  before_action :set_filters, only: :index
  before_action :set_filter, only: [:show, :update, :destroy]

  def index
    render json: @filters, each_serializer: REST::FilterSerializer, rules_requested: true
  end

  def create
    @filter = current_account.custom_filters.create!(resource_params)

    render json: @filter, serializer: REST::FilterSerializer, rules_requested: true
  end

  def show
    render json: @filter, serializer: REST::FilterSerializer, rules_requested: true
  end

  def update
    @filter.update!(resource_params)

    render json: @filter, serializer: REST::FilterSerializer, rules_requested: true
  end

  def destroy
    @filter.destroy!
    render_empty
  end

  private

  def set_filters
    @filters = current_account.custom_filters.includes(:keywords)
  end

  def set_filter
    @filter = current_account.custom_filters.find(params[:id])
  end

  def resource_params
    params.permit(:title, :expires_in, :filter_action, context: [], keywords_attributes: [:id, :keyword, :whole_word, :_destroy])
  end
end
