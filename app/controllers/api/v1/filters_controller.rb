# frozen_string_literal: true

class Api::V1::FiltersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    render json: current_account.custom_filters, each_serializer: REST::FilterSerializer
  end

  def create
    # TODO
  end

  def show
    render json: current_account.custom_filters.find(params[:id]), serializer: REST::FilterSerializer
  end

  def update
    # TODO
  end

  def destroy
    # TODO
  end
end
