# frozen_string_literal: true

module Admin::SettingsHelper
  def captcha_available?
    ENV['HCAPTCHA_SECRET_KEY'].present? && ENV['HCAPTCHA_SITE_KEY'].present?
  end

  def login_activity_title(login_activity)
    t (login_activity.success? ? 'successful_sign_in_html' : 'failed_sign_in_html'),
      scope: :login_activities,
      method: content_tag(:span,
                          login_activity.omniauth? ? t(login_activity.provider, scope: 'auth.providers') : t(login_activity.authentication_method, scope: 'login_activities.authentication_methods'),
                          class: 'target'),
      ip: content_tag(:span,
                      login_activity.ip,
                      class: 'target'),
      browser: content_tag(:span,
                           t('sessions.description',
                             browser: t("sessions.browsers.#{login_activity.browser}", default: login_activity.browser.to_s),
                             platform: t("sessions.platforms.#{login_activity.platform}", default: login_activity.platform.to_s)),
                           class: 'target',
                           title: login_activity.user_agent)
  end
end
