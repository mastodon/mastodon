# frozen_string_literal: true

class BlacklistedEmailValidator < ActiveModel::Validator
  def validate(user)
    return if user.valid_invitation? || user.email.blank?

    @email = user.email

    user.errors.add(:email, :blocked) if blocked_email_provider?
    user.errors.add(:email, :taken) if blocked_canonical_email?
  end

  private

  def blocked_email_provider?
    disallowed_through_email_domain_block? || disallowed_through_configuration? || not_allowed_through_configuration?
  end

  def blocked_canonical_email?
    CanonicalEmailBlock.block?(@email)
  end

  def disallowed_through_email_domain_block?
    EmailDomainBlock.block?(@email)
  end

  def not_allowed_through_configuration?
    return false if Rails.configuration.x.email_domains_whitelist.blank?

    domains = Rails.configuration.x.email_domains_whitelist.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})$", true)

    @email !~ regexp
  end

  def disallowed_through_configuration?
    return false if Rails.configuration.x.email_domains_blacklist.blank?

    domains = Rails.configuration.x.email_domains_blacklist.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})", true)

    regexp.match?(@email)
  end
end
