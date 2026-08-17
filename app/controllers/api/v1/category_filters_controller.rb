# frozen_string_literal: true

class Api::V1::CategoryFiltersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create, :destroy]
  before_action :require_user!
  before_action :set_category, only: [:create, :destroy]

  def index
    @category_filters = current_account.account_category_filters.includes(:category)
    render json: @category_filters, each_serializer: REST::CategoryFilterSerializer
  end

  def create
    if @category.mandatory_for_readers?
      render json: { error: I18n.t('api.category_filters.errors.mandatory') }, status: 422
      return
    end

    @category_filter = current_account.account_category_filters.find_or_create_by!(category: @category)
    current_user.regenerate_home_feed!
    render json: @category_filter, serializer: REST::CategoryFilterSerializer
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: 422
  end

  def destroy
    @category_filter = current_account.account_category_filters.find_by!(category: @category)
    @category_filter.destroy!
    current_user.regenerate_home_feed!
    render_empty
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('api.category_filters.errors.not_found') }, status: 404
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('api.category_filters.errors.category_not_found') }, status: 404
  end
end
