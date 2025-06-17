# frozen_string_literal: true

class UserEmailValidator < ActiveModel::Validator
  def validate(user)
    return if user.valid_invitation? || user.email.blank?

    user.errors.add(:email, :blocked) if blocked_email_provider?(user.email, user.sign_up_ip)
    user.errors.add(:email, :taken) if blocked_canonical_email?(user.email)
  end

  private

  def blocked_email_provider?(email, ip)
    disallowed_through_email_domain_block?(email, ip) || disallowed_through_configuration?(email) || not_allowed_through_configuration?(email)
  end

  def blocked_canonical_email?(email)
    CanonicalEmailBlock.block?(email)
  end

  def disallowed_through_email_domain_block?(email, ip)
    EmailDomainBlock.block?(email, attempt_ip: ip)
  end

  def not_allowed_through_configuration?(email)
    return false if allowed_email_domains.blank?

    domains = allowed_email_domains.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})$", true)

    email !~ regexp
  end

  def disallowed_through_configuration?(email)
    return false if denied_email_domains.blank?

    domains = denied_email_domains.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})", true)

    regexp.match?(email)
  end

  def allowed_email_domains
    Rails.configuration.x.email_domains.allowlist
  end

  def denied_email_domains
    Rails.configuration.x.email_domains.denylist
  end
end
