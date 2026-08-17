# frozen_string_literal: true

class Api::V1::CategoryNotificationsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create, :destroy]
  before_action :require_user!
  before_action :set_category, only: [:create, :destroy]

  def index
    @category_notifications = current_account.account_category_notifications.includes(:category)
    render json: @category_notifications, each_serializer: REST::CategoryNotificationSerializer
  end

  def create
    @category_notification = current_account.account_category_notifications.find_or_create_by!(category: @category)
    render json: @category_notification, serializer: REST::CategoryNotificationSerializer
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: 422
  end

  def destroy
    @category_notification = current_account.account_category_notifications.find_by!(category: @category)
    @category_notification.destroy!
    render_empty
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('api.category_notifications.errors.not_found') }, status: 404
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('api.category_notifications.errors.category_not_found') }, status: 404
  end
end
