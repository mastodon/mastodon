# frozen_string_literal: true

require 'resolv'

class EmailMxValidator < ActiveModel::Validator
  def validate(user)
    return if user.email.blank?

    domain = get_domain(user.email)

    if domain.blank? || domain.include?('..')
      user.errors.add(:email, :invalid)
    elsif !on_allowlist?(domain)
      resolved_ips, resolved_domains = resolve_mx(domain)

      if resolved_ips.empty?
        user.errors.add(:email, :unreachable)
      elsif email_domain_blocked?(resolved_domains, user.sign_up_ip)
        user.errors.add(:email, :blocked)
      end
    end
  end

  private

  def get_domain(value)
    _, domain = value.split('@', 2)

    return nil if domain.nil?

    TagManager.instance.normalize_domain(domain)
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def on_allowlist?(domain)
    return false if Rails.configuration.x.email_domains_allowlist.blank?

    Rails.configuration.x.email_domains_allowlist.include?(domain)
  end

  def resolve_mx(domain)
    records = []
    ips     = []

    Resolv::DNS.open do |dns|
      dns.timeouts = 5

      records = dns.getresources(domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }
      next if records == [''] # This domain explicitly rejects emails

      ([domain] + records).uniq.each do |hostname|
        ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s })
        ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::AAAA).to_a.map { |e| e.address.to_s })
      end
    end

    [ips, records]
  end

  def email_domain_blocked?(domains, attempt_ip)
    EmailDomainBlock.block?(domains, attempt_ip: attempt_ip)
  end
end
