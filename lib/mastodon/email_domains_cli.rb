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

    desc 'list', 'list E-mail domain blocks'
    long_desc <<-LONG_DESC
      list up all E-mail domain blocks.
    LONG_DESC
    def list
      EmailDomainBlock.where(parent_id: nil).includes(:children).order(id: 'DESC').find_each do |entry|
        say(entry.domain.to_s, :green)
        entry.children.order(id: 'DESC').find_each do |child|
          say("  #{child.domain}", :yellow)
        end
      end
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
        if EmailDomainBlock.where(domain: domain).exists?
          say("#{domain} is already blocked.", :yellow)
          next
        end

        email_domain_block = EmailDomainBlock.new(domain: domain, with_dns_records: options[:with_dns_records] || false)
        email_domain_block.save!

        say("#{domain} was blocked.", :green)

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

        (hostnames + ips).uniq.each do |hostname|
          another_email_domain_block = EmailDomainBlock.new(domain: hostname, parent: email_domain_block)
          if EmailDomainBlock.where(domain: hostname).exists?
            say("#{hostname} is already blocked.", :yellow)
            next
          end
          another_email_domain_block.save!
          say("#{hostname} was blocked. (from #{domain})", :green)
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

      domains.each do |domain|
        unless EmailDomainBlock.where(domain: domain).exists?
          say("#{domain} is not yet blocked.", :yellow)
          next
        end

        result = EmailDomainBlock.where(domain: domain).destroy_all
        if result
          say("#{domain} was unblocked.", :green)
        else
          say("#{domain} was not unblocked. 'destroy' returns false.", :red)
        end
      end
    end
  end
end
