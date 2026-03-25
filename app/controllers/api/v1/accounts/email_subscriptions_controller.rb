# frozen_string_literal: true

class Api::V1::Accounts::EmailSubscriptionsController < Api::BaseController
  before_action :set_account
  before_action :require_feature_enabled!
  before_action :require_account_permissions!

  def create
    @account.email_subscriptions.create!(email: params[:email], locale: I18n.locale)
    render_empty
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e).as_json, status: 422
  end

  private

  def set_account
    @account = Account.local.find(params[:account_id])
  end

  def require_feature_enabled!
    head 404 unless Mastodon::Feature.email_subscriptions_enabled?
  end

  def require_account_permissions!
    head 404 if @account.unavailable? || !@account.user_can?(:manage_email_subscriptions) || !@account.user_email_subscriptions_enabled?
  end
end
