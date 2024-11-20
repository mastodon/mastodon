# frozen_string_literal: true

require 'concurrent'
require_relative 'base'

module Mastodon::CLI
  class EmailDomainBlocks < Base
    desc 'list', 'List blocked e-mail domains'
    def list
      EmailDomainBlock.parents.find_each do |parent|
        say(parent.domain.to_s, :white)

        shell.indent do
          EmailDomainBlock.where(parent_id: parent.id).find_each do |child|
            say(child.domain, :cyan)
          end
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
      given domains' MX records will be made and the results will also be blocked.
      This can be helpful if you are blocking an e-mail server that has many
      different domains pointing to it as it allows you to essentially block
      it at the root.
    LONG_DESC
    def add(*domains)
      fail_with_message 'No domain(s) given' if domains.empty?

      skipped = 0
      processed = 0

      domains.each do |domain|
        if EmailDomainBlock.exists?(domain: domain)
          say("#{domain} is already blocked.", :yellow)
          skipped += 1
          next
        end

        other_domains = []
        other_domains = DomainResource.new(domain).mx if options[:with_dns_records]

        email_domain_block = EmailDomainBlock.new(domain: domain, other_domains: other_domains)
        email_domain_block.save!
        processed += 1

        (email_domain_block.other_domains || []).uniq.each do |hostname|
          another_email_domain_block = EmailDomainBlock.new(domain: hostname, parent: email_domain_block)

          if EmailDomainBlock.exists?(domain: hostname)
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
      fail_with_message 'No domain(s) given' if domains.empty?

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
          processed += children_count + 1
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
