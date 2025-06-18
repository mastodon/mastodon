# frozen_string_literal: true

class UserEmailValidator < ActiveModel::Validator
  SEPARATOR = '|'

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

    domains = escaped_domains(allowed_email_domains)

    email !~ allowed_domain_pattern(domains)
  end

  def disallowed_through_configuration?(email)
    return false if denied_email_domains.blank?

    domains = escaped_domains(denied_email_domains)

    denied_domain_pattern(domains).match?(email)
  end

  def allowed_domain_pattern(domains)
    Regexp.new("@(.+\\.)?(#{domains})$", true)
  end

  def denied_domain_pattern(domains)
    Regexp.new("@(.+\\.)?(#{domains})", true)
  end

  def escaped_domains(domains)
    domains
      .split(SEPARATOR)
      .map { |domain| Regexp.escape(domain) }
      .join(SEPARATOR)
      .to_s
  end

  def allowed_email_domains
    Rails.configuration.x.email_domains.allowlist
  end

  def denied_email_domains
    Rails.configuration.x.email_domains.denylist
  end
end
