# frozen_string_literal: true

class Admin::EmailSubscriptions::AccountsController < Admin::BaseController
  before_action :require_enabled!
  before_action :set_account

  def show
    authorize :email_subscription, :show?
    @email_subscriptions_count = EmailSubscription.where(account: @account).count
    @email_subscriptions = EmailSubscription.where(account: @account).page(params[:page])
  end

  def enable
    authorize :email_subscription, :enable?
    @account.user.settings['email_subscriptions'] = true
    @account.user.save!
    redirect_to admin_email_subscriptions_account_path(@account.id)
  end

  def disable
    authorize :email_subscription, :disable?
    @account.user.settings['email_subscriptions'] = false
    @account.user.save!
    redirect_to admin_email_subscriptions_account_path(@account.id)
  end

  private

  def require_enabled!
    raise ActionController::RoutingError, 'Feature disabled' unless Rails.application.config.x.email_subscriptions
  end

  def set_account
    @account = Account.find(params[:id])
  end
end
