# frozen_string_literal: true

module Admin::SettingsHelper
  def captcha_available?
    Rails.configuration.x.captcha.secret_key.present? && Rails.configuration.x.captcha.site_key.present?
  end

  def login_activity_title(activity)
    t(
      "login_activities.#{login_activity_key(activity)}",
      method: login_activity_method_string(activity)
    )
  end

  def login_activity_browser_description(activity)
    t(
      'sessions.description',
      browser: t(activity.browser, scope: 'sessions.browsers', default: activity.browser.to_s),
      platform: t(activity.platform, scope: 'sessions.platforms', default: activity.platform.to_s)
    )
  end

  private

  def login_activity_key(activity)
    activity.success? ? 'successful_sign_in' : 'failed_sign_in'
  end

  def login_activity_method_string(activity)
    if activity.omniauth?
      t("auth.providers.#{activity.provider}")
    else
      t("login_activities.authentication_methods.#{activity.authentication_method}")
    end
  end
end
