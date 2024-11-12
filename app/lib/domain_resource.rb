# frozen_string_literal: true

class DomainResource
  attr_reader :domain

  TIMEOUT_LIMIT = 5

  def initialize(domain)
    @domain = domain
  end

  def mx
    Resolv::DNS.open do |dns|
      dns.timeouts = TIMEOUT_LIMIT
      dns
        .getresources(domain, Resolv::DNS::Resource::IN::MX)
        .to_a
        .map { |mx| mx.exchange.to_s }
        .compact_blank
    end
  end
end
