# frozen_string_literal: true

class BlacklistedEmailValidator < ActiveModel::Validator
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
    return false if Rails.configuration.x.email_domains_whitelist.blank?

    domains = Rails.configuration.x.email_domains_whitelist.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})$", true)

    email !~ regexp
  end

  def disallowed_through_configuration?(email)
    return false if Rails.configuration.x.email_domains_blacklist.blank?

    domains = Rails.configuration.x.email_domains_blacklist.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})", true)

    regexp.match?(email)
  end
end
