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

    desc 'list', 'list E-mail domain blocks'
    long_desc <<-LONG_DESC
      list up all E-mail domain blocks.
    LONG_DESC
    def list
      EmailDomainBlock.where(parent_id: nil).order(id: 'DESC').find_each do |entry|
        say(entry.domain.to_s, :white)
        EmailDomainBlock.where(parent_id: entry.id).order(id: 'DESC').find_each do |child|
          say("  #{child.domain}", :cyan)
        end
      end
    end

    option :with_dns_records, type: :boolean
    desc 'add [DOMAIN...]', 'add E-mail domain blocks'
    long_desc <<-LONG_DESC
      add E-mail domain blocks from a given DOMAIN.

      When the --with-dns-records option is given, An attempt to resolve the
      given domain's DNS records will be made and the results will also be
      blacklisted.
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
            skipped += 1
            next
          end
          another_email_domain_block.save!
          processed += 1
        end
      end

      say("Added #{processed}, skipped #{skipped}", color(processed, skipped, 0))
    end

    desc 'remove [DOMAIN...]', 'remove E-mail domain blocks'
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
          say("#{domain} was not unblocked. 'destroy' returns false.", :red)
          failed += 1
        end
      end

      say("Removed #{processed}, skipped #{skipped}, failed #{failed}", color(processed, skipped, failed))
    end

    private

    def color(processed, skipped, failed)
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
