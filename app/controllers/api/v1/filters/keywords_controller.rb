# frozen_string_literal: true

class Api::V1::Filters::KeywordsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:filters' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:filters' }, except: [:index, :show]
  before_action :require_user!

  before_action :set_keywords, only: :index
  before_action :set_keyword, only: [:show, :update, :destroy]

  def index
    render json: @keywords, each_serializer: REST::FilterKeywordSerializer
  end

  def create
    @keyword = current_account.custom_filters.find(params[:filter_id]).keywords.create!(resource_params)

    render json: @keyword, serializer: REST::FilterKeywordSerializer
  end

  def show
    render json: @keyword, serializer: REST::FilterKeywordSerializer
  end

  def update
    @keyword.update!(resource_params)

    render json: @keyword, serializer: REST::FilterKeywordSerializer
  end

  def destroy
    @keyword.destroy!
    render_empty
  end

  private

  def set_keywords
    filter = current_account.custom_filters.includes(:keywords).find(params[:filter_id])
    @keywords = filter.keywords
  end

  def set_keyword
    @keyword = CustomFilterKeyword.includes(:custom_filter).where(custom_filter: { account: current_account }).find(params[:id])
  end

  def resource_params
    params.permit(:keyword, :whole_word)
  end
end
