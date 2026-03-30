# frozen_string_literal: true

module DomainHelpers
  def configure_mx(domain:, exchange:, ip_v4_addr: '2.3.4.5', ip_v6_addr: 'fd00::2')
    resolver = instance_double(Resolv::DNS, :timeouts= => nil)

    allow(resolver).to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::MX)
      .and_return([double_mx(exchange)])
    allow(resolver)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::A)
      .and_return([])
    allow(resolver)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::AAAA)
      .and_return([])
    allow(resolver)
      .to receive(:getresources)
      .with(exchange, Resolv::DNS::Resource::IN::A)
      .and_return([double_resource_v4(ip_v4_addr)])
    allow(resolver)
      .to receive(:getresources)
      .with(exchange, Resolv::DNS::Resource::IN::AAAA)
      .and_return([double_resource_v6(ip_v6_addr)])
    allow(Resolv::DNS)
      .to receive(:open)
      .and_yield(resolver)
  end

  def configure_dns(domain:, results:)
    resolver = instance_double(Resolv::DNS, :timeouts= => nil)

    allow(resolver).to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::MX)
      .and_return(results)
    allow(resolver)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::A)
      .and_return(results)
    allow(resolver)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::AAAA)
      .and_return(results)
    allow(Resolv::DNS)
      .to receive(:open)
      .and_yield(resolver)
  end

  def local_domain_uri
    Addressable::URI.parse("//#{Rails.configuration.x.local_domain}")
  end

  private

  def double_mx(exchange)
    instance_double(Resolv::DNS::Resource::MX, exchange: exchange)
  end

  def double_resource_v4(addr)
    instance_double(Resolv::DNS::Resource::IN::A, address: addr)
  end

  def double_resource_v6(addr)
    instance_double(Resolv::DNS::Resource::IN::AAAA, address: addr)
  end
end
