# frozen_string_literal: true

module Auth::HcaptchaConcern
  extend ActiveSupport::Concern

  include Hcaptcha::Adapters::ViewMethods

  HCAPTCHA_DIRECTIVES = %w(
    connect_src
    frame_src
    script_src
    style_src
  ).freeze

  HCAPTCHA_SOURCES = %w(
    https://*.hcaptcha.com
    https://hcaptcha.com
  ).freeze

  def hcaptcha_available?
    Rails.configuration.x.captcha.secret_key.present? && Rails.configuration.x.captcha.site_key.present?
  end

  def check_hcaptcha!
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

  def render_hcaptcha
    return unless hcaptcha_required?

    hcaptcha_tags
  end

  private

  def captcha_adjusted_policy
    request.content_security_policy.clone.tap do |policy|
      populate_captcha_policy(policy)
    end
  end

  def populate_captcha_policy(policy)
    HCAPTCHA_DIRECTIVES.each do |directive|
      values = policy.send(directive)

      HCAPTCHA_SOURCES.each do |source|
        values << source unless values.include?(source) || values.include?('https:')
      end

      policy.send(directive, *values)
    end
  end
end
