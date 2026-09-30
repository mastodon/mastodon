# frozen_string_literal: true

module User::Activity
  extend ActiveSupport::Concern

  # The home and list feeds will be stored for this amount of time, and status
  # fan-out to followers will include only people active within this time frame.
  #
  # Lowering the duration may improve performance if many people sign up, but
  # most will not check their feed every day. Raising the duration reduces the
  # amount of background processing that happens when people become active.
  ACTIVE_DURATION = ENV.fetch('USER_ACTIVE_DAYS', 7).to_i.days

  # If a user hasn't logged in in this period of time, we consider new attempts suspicious
  # and start a security code challenge to verify said user
  SUSPICIOUS_INACTIVITY_DURATION = 90.days.freeze

  included do
    scope :signed_in_recently, -> { where(current_sign_in_at: ACTIVE_DURATION.ago..) }
    scope :not_signed_in_recently, -> { where(current_sign_in_at: ...ACTIVE_DURATION.ago) }
  end

  def signed_in_recently?
    current_sign_in_at.present? && current_sign_in_at >= ACTIVE_DURATION.ago
  end

  # We consider suspicious any log in of users that have been inactive for SUSPICIOUS_INACTIVITY_DURATION
  # Users with OTP enabled or that are managed through SSO, LDAP or PAM are not taken into account
  def suspicious_inactive_sign_in?
    !two_factor_enabled? &&
      encrypted_password? &&
      current_sign_in_at? &&
      current_sign_in_at < SUSPICIOUS_INACTIVITY_DURATION.ago
  end

  private

  def inactive_since_duration?
    last_sign_in_at < ACTIVE_DURATION.ago
  end
end
