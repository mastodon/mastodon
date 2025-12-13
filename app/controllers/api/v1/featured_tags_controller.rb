# frozen_string_literal: true

class Api::V1::FeaturedTagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index

  before_action :require_user!
  before_action :set_featured_tags, only: :index
  before_action :set_featured_tag, except: [:index, :create]

  def index
    render json: @featured_tags, each_serializer: REST::FeaturedTagSerializer
  end

  def create
    featured_tag = CreateFeaturedTagService.new.call(current_account, params.require(:name))
    render json: featured_tag, serializer: REST::FeaturedTagSerializer
  end

  def destroy
    RemoveFeaturedTagService.new.call(current_account, @featured_tag)
    render_empty
  end

  private

  def set_featured_tag
    @featured_tag = current_account.featured_tags.find(params[:id])
  end

  def set_featured_tags
    @featured_tags = current_account.featured_tags.order(statuses_count: :desc)
  end
end
