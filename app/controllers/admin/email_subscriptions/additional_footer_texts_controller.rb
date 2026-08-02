# frozen_string_literal: true

class Admin::EmailSubscriptions::AdditionalFooterTextsController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_email_subscriptions_path
  end
end
