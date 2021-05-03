# frozen_string_literal: true

require 'concurrent'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class EmailDomainBlocksCLI < Thor
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    desc 'list', 'List blocked e-mail domains'
    def list
      EmailDomainBlock.where(parent_id: nil).order(id: 'DESC').find_each do |entry|
        say(entry.domain.to_s, :white)

        EmailDomainBlock.where(parent_id: entry.id).order(id: 'DESC').find_each do |child|
          say("  #{child.domain}", :cyan)
        end
      end
    end

    option :with_dns_records, type: :boolean
    desc 'add DOMAIN...', 'Block e-mail domain(s)'
    long_desc <<-LONG_DESC
      Blocking an e-mail domain prevents users from signing up
      with e-mail addresses from that domain. You can provide one or
      multiple domains to the command.

      When the --with-dns-records option is given, an attempt to resolve the
      given domains' DNS records will be made and the results (A, AAAA and MX) will
      also be blocked. This can be helpful if you are blocking an e-mail server that
      has many different domains pointing to it as it allows you to essentially block
      it at the root.
    LONG_DESC
    def add(*domains)
      if domains.empty?
        say('No domain(s) given', :red)
        exit(1)
      end

      skipped = 0
      processed = 0

      domains.each do |domain|
        if EmailDomainBlock.where(domain: domain).exists?
          say("#{domain} is already blocked.", :yellow)
          skipped += 1
          next
        end

        email_domain_block = EmailDomainBlock.new(domain: domain, with_dns_records: options[:with_dns_records] || false)
        email_domain_block.save!
        processed += 1

        next unless email_domain_block.with_dns_records?

        hostnames = []
        ips       = []

        Resolv::DNS.open do |dns|
          dns.timeouts = 5
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
            skipped += 1
            next
          end

          another_email_domain_block.save!
          processed += 1
        end
      end

      say("Added #{processed}, skipped #{skipped}", color(processed, 0))
    end

    desc 'remove DOMAIN...', 'Remove e-mail domain blocks'
    def remove(*domains)
      if domains.empty?
        say('No domain(s) given', :red)
        exit(1)
      end

      skipped = 0
      processed = 0
      failed = 0

      domains.each do |domain|
        entry = EmailDomainBlock.find_by(domain: domain)

        if entry.nil?
          say("#{domain} is not yet blocked.", :yellow)
          skipped += 1
          next
        end

        children_count = EmailDomainBlock.where(parent_id: entry.id).count
        result = entry.destroy

        if result
          processed += 1 + children_count
        else
          say("#{domain} could not be unblocked.", :red)
          failed += 1
        end
      end

      say("Removed #{processed}, skipped #{skipped}, failed #{failed}", color(processed, failed))
    end

    private

    def color(processed, failed)
      if !processed.zero? && failed.zero?
        :green
      elsif failed.zero?
        :yellow
      else
        :red
      end
    end
  end
end
