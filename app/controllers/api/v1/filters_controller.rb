# frozen_string_literal: true

class Api::V1::FiltersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:filters' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:filters' }, except: [:index, :show]
  before_action :require_user!
  before_action :set_filters, only: :index
  before_action :set_filter, only: [:show, :update, :destroy]

  def index
    render json: @filters, each_serializer: REST::V1::FilterSerializer
  end

  def create
    ApplicationRecord.transaction do
      filter_category = current_account.custom_filters.create!(resource_params)
      @filter = filter_category.keywords.create!(keyword_params)
    end

    render json: @filter, serializer: REST::V1::FilterSerializer
  end

  def show
    render json: @filter, serializer: REST::V1::FilterSerializer
  end

  def update
    ApplicationRecord.transaction do
      @filter.update!(keyword_params)
      @filter.custom_filter.assign_attributes(filter_params)
      raise Mastodon::ValidationError, I18n.t('filters.errors.deprecated_api_multiple_keywords') if @filter.custom_filter.changed? && @filter.custom_filter.keywords.count > 1

      @filter.custom_filter.save!
    end

    render json: @filter, serializer: REST::V1::FilterSerializer
  end

  def destroy
    @filter.destroy!
    render_empty
  end

  private

  def set_filters
    @filters = CustomFilterKeyword.includes(:custom_filter).where(custom_filter: { account: current_account })
  end

  def set_filter
    @filter = CustomFilterKeyword.includes(:custom_filter).where(custom_filter: { account: current_account }).find(params[:id])
  end

  def resource_params
    params.permit(:phrase, :expires_in, :irreversible, context: [])
  end

  def filter_params
    resource_params.slice(:expires_in, :irreversible, :context)
  end

  def keyword_params
    resource_params.slice(:phrase, :whole_word)
  end
end
