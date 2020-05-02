# frozen_string_literal: true

require 'concurrent'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class EmailDomainsCLI < Thor
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    option :with_dns_records, type: :boolean
    desc 'block [DOMAIN...]', 'Block E-mail domains'
    long_desc <<-LONG_DESC
      Block E-mail domains from a given DOMAIN.

      When the --with-dns-records option is given, An attempt to resolve the
      given domain's DNS records will be made and the results will also be
      blacklisted.
    LONG_DESC
    def block(*domains)

      if domains.empty?
        say('No domain(s) given', :red)
        exit(1)
      end

      domains.each do |domain|
        email_domain_block = EmailDomainBlock.new(domain: domain, with_dns_records: options[:with_dns_records] || false)
        email_domain_block.save!

        log_action :create, email_domain_block
        say("Blocked domain #{domain}", :green)

        next unless email_domain_block.with_dns_records?

        hostnames = []
        ips       = []

        Resolv::DNS.open do |dns|
          dns.timeouts = 1
          hostnames = dns.getresources(email_domain_block.domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }

          ([email_domain_block.domain] + hostnames).uniq.each do |hostname|
            ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s })
            ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::AAAA).to_a.map { |e| e.address.to_s })
          end
        end

        (hostnames + ips).each do |hostname|
          another_email_domain_block = EmailDomainBlock.new(domain: hostname, parent: email_domain_block)
          another_email_domain_block.save!
          log_action :create, another_email_domain_block
          say("Blocked domain #{hostname}", :green)
        end
      end
    end

    desc 'unblock [DOMAIN...]', 'Unblock E-mail domains'
    long_desc <<-LONG_DESC
      Unblock E-mail domains from a given DOMAIN.
    LONG_DESC
    def unblock(*domains)
      if domains.empty?
        say('No domain(s) given', :red)
        exit(1)
      end

      EmailDomainBlock.where(domain: domains).find_each do |entry|
        entry.destroy!
        log_action :create, entry
        say("Unblocked domain #{domain}", :green)
      end
    end
  end
end
