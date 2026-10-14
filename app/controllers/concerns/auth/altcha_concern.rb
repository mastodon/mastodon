# frozen_string_literal: true

module Auth::AltchaConcern
  extend ActiveSupport::Concern
  include ActionView::Helpers::AssetTagHelper
  include Vite::TagsHelper

  HMAC_SECRET = Rails.application.secret_key_base

  included do
    helper_method :render_altcha
  end

  def altcha_available?
    true
  end

  def check_altcaptcha!
    restored = Altcha::V2::Payload.from_json(Base64.decode64(params[:altcha]))
    result = Altcha::V2.verify_solution(
      restored.challenge,
      restored.solution,
      hmac_signature_secret: HMAC_SECRET
    )

    if result.verified
      true
    else
      if block_given?
        message = if result.expired
                    'Challenge expired'
                  elsif result.invalid_signature
                    'Invalid challenge signature'
                  else
                    'Incorrect solution'
                  end
        yield message
      end

      false
    end
  end

  # def extend_csp_for_captcha!
  #   return unless captcha_required? && request.content_security_policy.present?

  #   request.content_security_policy = captcha_adjusted_policy
  # end

  def render_altcha
    options = Altcha::V2::CreateChallengeOptions.new(
      algorithm: 'PBKDF2/SHA-256',
      cost: 5_000,
      counter: SecureRandom.random_number(5_000..10_000),
      hmac_signature_secret: HMAC_SECRET
    )

    challenge = Altcha::V2.create_challenge(options)
    encoded_json = challenge.to_json # .gsub('"', '\\\"')

    [
      vite_javascript_tag('altcha.ts'),
      "<altcha-widget challenge='#{encoded_json}'></altcha-widget>",
    ].join("\n").html_safe
  end
end
