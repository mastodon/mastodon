# frozen_string_literal: true

class Scheduler::EmailDomainBlockRefreshScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  def perform
    Resolv::DNS.open do |dns|
      dns.timeouts = 5

      EmailDomainBlock.find_each do |email_domain_block|
        ips = begin
          if ip?(email_domain_block.domain)
            [email_domain_block.domain]
          else
            resources = dns.getresources(email_domain_block.domain, Resolv::DNS::Resource::IN::A).to_a + dns.getresources(email_domain_block.domain, Resolv::DNS::Resource::IN::AAAA).to_a
            resources.map { |resource| resource.address.to_s }
          end
        end

        email_domain_block.update(ips: ips, last_refresh_at: Time.now.utc)
      end
    end
  end

  def ip?(str)
    str =~ Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex])
  end
end
