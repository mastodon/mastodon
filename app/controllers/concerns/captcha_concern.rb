# frozen_string_literal: true

module CaptchaConcern
  extend ActiveSupport::Concern
  include Hcaptcha::Adapters::ViewMethods

  CAPTCHA_TIMEOUT = 2.hours.freeze

  included do
    helper_method :render_captcha_if_needed
  end

  def captcha_available?
    ENV['HCAPTCHA_SECRET_KEY'].present? && ENV['HCAPTCHA_SITE_KEY'].present?
  end

  def captcha_enabled?
    captcha_available? && Setting.captcha_enabled
  end

  def captcha_recently_passed?
    session[:captcha_passed_at].present? && session[:captcha_passed_at] >= CAPTCHA_TIMEOUT.ago
  end

  def captcha_required?
    captcha_enabled? && !current_user && !(@invite.present? && @invite.valid_for_use? && !@invite.max_uses.nil?) && !captcha_recently_passed?
  end

  def clear_captcha!
    session.delete(:captcha_passed_at)
  end

  def check_captcha!
    return true unless captcha_required?

    if verify_hcaptcha
      session[:captcha_passed_at] = Time.now.utc
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
    policy = request.content_security_policy
    return unless captcha_required? && policy.present?

    %w(script_src frame_src style_src connect_src).each do |directive|
      values = policy.send(directive)
      values << 'https://hcaptcha.com' unless values.include?('https://hcaptcha.com') || values.include?('https:')
      values << 'https://*.hcaptcha.com' unless values.include?('https://*.hcaptcha.com') || values.include?('https:')
      policy.send(directive, *values)
    end
  end

  def render_captcha_if_needed
    return unless captcha_required?

    hcaptcha_tags
  end
end
