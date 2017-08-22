# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController

  before_action :set_account
  before_action -> { doorkeeper_authorize! :read }, only: [:index]
  before_action -> { doorkeeper_authorize! :write }, except: [:index]
  before_action :require_user!

  respond_to :json

  def index
    render json: current_favourite_tags
  end

  def create
    tag = find_or_init_tag
    @favourite_tag = FavouriteTag.new(account: @account, tag: tag, visibility: favourite_tag_visibility)
    if @favourite_tag.save
      render json: @favourite_tag.to_json_for_api
    else
      render json: find_fav_tag_by(tag).to_json_for_api, status: :conflict
    end
  end

  def destroy
    tag = find_tag
    @favourite_tag = find_fav_tag_by(tag)
    if @favourite_tag.nil?
      render json: { succeeded: false }, status: :not_found
    else
      @favourite_tag.destroy
      render json: { succeeded: true }
    end
  end

  private

  def tag_params
    params.permit(:tag, :visibility)
  end

  def set_account
    @account = current_user.account
  end

  def find_or_init_tag
    Tag.find_or_initialize_by(name: tag_params[:tag])
  end
  
  def find_tag
    Tag.find_by(name: tag_params[:tag])
  end

  def find_fav_tag_by(tag)
    @account.favourite_tags.find_by(tag: tag)
  end

  def favourite_tag_visibility
    tag_params[:visibility].nil? ? 'public' : tag_params[:visibility]
  end
  
  def current_favourite_tags
    current_account.favourite_tags.includes(:tag).map(&:to_json_for_api)
  end
end
