# frozen_string_literal: true

class Admin::EmailSubscriptionsController < Admin::BaseController
  def index
    authorize :email_subscription, :index?

    @enabled = Setting.email_subscriptions
    @roles = UserRole.where('permissions & ? != 0', UserRole::FLAGS[:manage_email_subscriptions] | UserRole::FLAGS[:administrator])
    @accounts = Account.local.where.associated(:email_subscriptions).includes(:user)
  end

  def disable
    authorize :email_subscription, :disable?
    Setting.email_subscriptions = false
    redirect_to admin_email_subscriptions_path, notice: I18n.t('admin.email_subscriptions.disabled_msg')
  end

  def purge
    authorize :email_subscription, :purge?
    Admin::EmailSubscriptionsPurgeWorker.perform_async
    redirect_to admin_email_subscriptions_path, notice: I18n.t('admin.email_subscriptions.purged_msg')
  end
end
