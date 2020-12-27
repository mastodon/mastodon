# frozen_string_literal: true

require 'resolv'

class EmailMxValidator < ActiveModel::Validator
  def validate(user)
    domain = get_domain(user.email)

    if domain.nil?
      user.errors.add(:email, I18n.t('users.invalid_email'))
    else
      ips, hostnames = resolve_mx(domain)
      if ips.empty?
        user.errors.add(:email, I18n.t('users.invalid_email_mx'))
      elsif on_blacklist?(hostnames + ips)
        user.errors.add(:email, I18n.t('users.blocked_email_provider'))
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

  def resolve_mx(domain)
    hostnames = []
    ips       = []

    Resolv::DNS.open do |dns|
      dns.timeouts = 5

      hostnames = dns.getresources(domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }

      ([domain] + hostnames).uniq.each do |hostname|
        ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s })
        ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::AAAA).to_a.map { |e| e.address.to_s })
      end
    end

    [ips, hostnames]
  end

  def on_blacklist?(values)
    EmailDomainBlock.where(domain: values.uniq).any?
  end
end
