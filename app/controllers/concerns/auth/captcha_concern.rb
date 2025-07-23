# frozen_string_literal: true

module Auth::CaptchaConcern
  extend ActiveSupport::Concern

  include Hcaptcha::Adapters::ViewMethods

  CAPTCHA_DIRECTIVES = %w(
    connect_src
    frame_src
    script_src
    style_src
  ).freeze

  CAPTCHA_SOURCES = %w(
    https://*.hcaptcha.com
    https://hcaptcha.com
  ).freeze

  included do
    helper_method :render_captcha
  end

  def captcha_available?
    Rails.configuration.x.captcha.secret_key.present? && Rails.configuration.x.captcha.site_key.present?
  end

  def captcha_enabled?
    captcha_available? && Setting.captcha_enabled
  end

  def captcha_user_bypass?
    false
  end

  def captcha_required?
    captcha_enabled? && !captcha_user_bypass?
  end

  def check_captcha!
    return true unless captcha_required?

    if verify_hcaptcha
      true
    else
      if block_given?
        message = flash[:hcaptcha_error]
        flash.delete(:hcaptcha_error)
        yield message
      end

      false
    end
  end

  def extend_csp_for_captcha!
    return unless captcha_required? && request.content_security_policy.present?

    request.content_security_policy = captcha_adjusted_policy
  end

  def render_captcha
    return unless captcha_required?

    hcaptcha_tags
  end

  private

  def captcha_adjusted_policy
    request.content_security_policy.clone.tap do |policy|
      populate_captcha_policy(policy)
    end
  end

  def populate_captcha_policy(policy)
    CAPTCHA_DIRECTIVES.each do |directive|
      values = policy.send(directive)

      CAPTCHA_SOURCES.each do |source|
        values << source unless values.include?(source) || values.include?('https:')
      end

      policy.send(directive, *values)
    end
  end
end
