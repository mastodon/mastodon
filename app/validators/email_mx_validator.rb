# frozen_string_literal: true

require 'resolv'

class EmailMxValidator < ActiveModel::Validator
  def validate(user)
    user.errors.add(:email, I18n.t('users.invalid_email')) if invalid_mx?(user.email)
  end

  private

  def invalid_mx?(value)
    _, domain = value.split('@', 2)

    return true if domain.nil?

    hostnames = []
    ips       = []

    Resolv::DNS.open do |dns|
      dns.timeouts = 1

      hostnames = dns.getresources(domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }

      ([domain] + hostnames).uniq.each do |hostname|
        ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s })
      end
    end

    ips.empty? || on_blacklist?(hostnames + ips)
  end

  def on_blacklist?(values)
    EmailDomainBlock.where(domain: values.uniq).any?
  end
end
