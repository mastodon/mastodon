# frozen_string_literal: true

module User::SignInToken
  extend ActiveSupport::Concern

  # If a user hasn't logged in in this period of time, we consider new attempts suspicious
  # and start a security code challenge to verify said user
  SUSPICIOUS_INACTIVITY_DURATION = 90.days.freeze

  included do
    attr_reader :sign_in_token_attempt
  end

  # We consider suspicious any log in of users that have been inactive for SUSPICIOUS_INACTIVITY_DURATION
  # Users with OTP enabled or that are managed through SSO, LDAP or PAM are not taken into account
  def suspicious_inactive_sign_in?
    !two_factor_enabled? &&
      encrypted_password? &&
      current_sign_in_at? &&
      current_sign_in_at < SUSPICIOUS_INACTIVITY_DURATION.ago
  end

  def valid_sign_in_token?(token)
    Devise.secure_compare(sign_in_token, token)
  end

  def sign_in_token_expired?
    sign_in_token_sent_at.nil? || sign_in_token_sent_at < 5.minutes.ago
  end

  def generate_sign_in_token
    self.sign_in_token         = Devise.friendly_token(6)
    self.sign_in_token_sent_at = Time.now.utc
  end

  def disable_sign_in_token!
    self.sign_in_token         = nil
    self.sign_in_token_sent_at = nil

    # Reset #current_sign_in_at so the system doesn't try to
    # send a security code for inactive accounts
    self.current_sign_in_at = Time.now.utc

    save!
  end
end
