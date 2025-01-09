# frozen_string_literal: true

module Auth::CaptchaConcern
  extend ActiveSupport::Concern

  include Hcaptcha::Adapters::ViewMethods
  include Mcaptcha::Adapters::ViewMethods

  included do
    helper_method :render_captcha
  end

  def captcha_available?
    if Rails.configuration.x.captcha.hcaptcha_secret_key.present? && Rails.configuration.x.captcha.hcaptcha_site_key.present?
      @hcaptcha_enabled = true
      true
    elsif Rails.configuration.x.captcha.mcaptcha_secret_key.present? && Rails.configuration.x.captcha.mcaptcha_site_key.present?
      @mcaptcha_enabled = true
      true
    else
      false
    end
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

  def check_hcaptcha!
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

  def check_mcaptcha!
    return true unless captcha_required?

    if verify_mcaptcha
      true
    else
      if block_given?
        message = flash[:mcaptcha_error]
        flash.delete(:mcaptcha_error)
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

      if @hcaptcha_enabled
        values << 'https://hcaptcha.com' unless values.include?('https://hcaptcha.com') || values.include?('https:')
        values << 'https://*.hcaptcha.com' unless values.include?('https://*.hcaptcha.com') || values.include?('https:')
      elsif @mcaptcha_enabled
        values << 'https://mcaptcha.org' unless values.include?('https://mcaptcha.org') || values.include?('https:')
        values << 'https://mcaptcha.*.*' unless values.include?('https://mcaptcha.*.*') || values.include?('https:')
      end

      policy.send(directive, *values)
    end

    request.content_security_policy = policy
  end

  def render_captcha
    return unless captcha_required?

    if @hcaptcha_enabled
      hcaptcha_tags
    elsif @mcaptcha_enabled
      mcaptcha_tags
    end
  end
end
