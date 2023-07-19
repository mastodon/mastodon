# frozen_string_literal: true

module Admin::SettingsHelper
  def captcha_available?
    ENV['HCAPTCHA_SECRET_KEY'].present? && ENV['HCAPTCHA_SITE_KEY'].present?
  end
end
