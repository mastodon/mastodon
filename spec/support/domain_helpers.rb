# frozen_string_literal: true

module DomainHelpers
  def configure_mx(domain:, exchange:, ip_v4_addr: '2.3.4.5', ip_v6_addr: 'fd00::2')
    {
      Resolv::DNS::Resource::IN::MX => [double_mx(exchange)],
      Resolv::DNS::Resource::IN::A => [],
      Resolv::DNS::Resource::IN::AAAA => [],
    }.each do |klass, values|
      stub_getresources(values, domain, klass)
    end

    {
      Resolv::DNS::Resource::IN::A => [double_resource_v4(ip_v4_addr)],
      Resolv::DNS::Resource::IN::AAAA => [double_resource_v4(ip_v6_addr)],
    }.each do |klass, values|
      stub_getresources(values, exchange, klass)
    end

    stub_resolv_dns_open
  end

  def configure_dns(domain:, results:)
    {
      Resolv::DNS::Resource::IN::MX => results,
      Resolv::DNS::Resource::IN::A => results,
      Resolv::DNS::Resource::IN::AAAA => results,
    }.each do |klass, values|
      stub_getresources(values, domain, klass)
    end

    stub_resolv_dns_open
  end

  def local_domain_uri
    Addressable::URI.parse("//#{Rails.configuration.x.local_domain}")
  end

  private

  def resolver
    @resolver ||= instance_double(Resolv::DNS, :timeouts= => nil)
  end

  def stub_getresources(values, *)
    allow(resolver)
      .to receive(:getresources)
      .with(*)
      .and_return(values)
  end

  def stub_resolv_dns_open
    allow(Resolv::DNS)
      .to receive(:open)
      .and_yield(resolver)
  end

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
