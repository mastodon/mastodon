# frozen_string_literal: true

require 'resolv'

class EmailMxValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    domain = get_domain(value)

    if domain.blank? || domain.include?('..')
      record.errors.add(attribute, :invalid)
    elsif !on_allowlist?(domain)
      resolved_ips, resolved_domains = resolve_mx(domain)

      if resolved_ips.empty?
        record.errors.add(attribute, :unreachable)
      elsif email_domain_blocked?([domain, *resolved_domains], options[:attempt_ip].is_a?(Symbol) ? record.public_send(options[:attempt_ip]) : nil)
        record.errors.add(attribute, :blocked)
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
