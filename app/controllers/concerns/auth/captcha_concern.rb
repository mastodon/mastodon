# frozen_string_literal: true

module Auth::CaptchaConcern
  extend ActiveSupport::Concern

  include Hcaptcha::Adapters::ViewMethods

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
    policy = request.content_security_policy&.clone

    return unless captcha_required? && policy.present?

    %w(script_src frame_src style_src connect_src).each do |directive|
      values = policy.send(directive)

      values << 'https://hcaptcha.com' unless values.include?('https://hcaptcha.com') || values.include?('https:')
      values << 'https://*.hcaptcha.com' unless values.include?('https://*.hcaptcha.com') || values.include?('https:')

      policy.send(directive, *values)
    end

    request.content_security_policy = policy
  end

  def render_captcha
    return unless captcha_required?

    hcaptcha_tags
  end
end
