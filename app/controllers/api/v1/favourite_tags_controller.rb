# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @favourite_tags = current_account.favourite_tags.order(:id).includes(:tag).map(&:to_json_for_api)
    render json: @favourite_tags
  end
end
