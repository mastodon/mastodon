# frozen_string_literal: true

require 'rubygems/package'
require_relative 'base'

module Mastodon::CLI
  class IpBlocks < Base
    option :severity, required: true, enum: IpBlock.severities.keys, desc: 'Severity of the block'
    option :comment, aliases: [:c], desc: 'Optional comment'
    option :duration, aliases: [:d], type: :numeric, desc: 'Duration of the block in seconds'
    option :force, type: :boolean, aliases: [:f], desc: 'Overwrite existing blocks'
    desc 'add IP...', 'Add one or more IP blocks'
    long_desc <<-LONG_DESC
      Add one or more IP blocks. You can use CIDR syntax to
      block IP ranges. You must specify --severity of the block. All
      options will be copied for each IP block you create in one command.

      You can add a --comment. If an IP block already exists for one of
      the provided IPs, it will be skipped unless you use the --force
      option to overwrite it.
    LONG_DESC
    def add(*addresses)
      fail_with_message 'No IP(s) given' if addresses.empty?

      skipped   = 0
      processed = 0
      failed    = 0

      addresses.each do |address|
        unless valid_ip_address?(address)
          say("#{address} is invalid", :red)
          failed += 1
          next
        end

        ip_block = IpBlock.find_by(ip: address)

        if ip_block.present? && !options[:force]
          say("#{address} is already blocked", :yellow)
          skipped += 1
          next
        end

        ip_block ||= IpBlock.new(ip: address)

        ip_block.severity   = options[:severity]
        ip_block.comment    = options[:comment] if options[:comment].present?
        ip_block.expires_in = options[:duration]

        if ip_block.save
          processed += 1
        else
          say("#{address} could not be saved", :red)
          failed += 1
        end
      end

      say("Added #{processed}, skipped #{skipped}, failed #{failed}", color(processed, failed))
    end

    option :force, type: :boolean, aliases: [:f], desc: 'Remove blocks for ranges that cover given IP(s)'
    desc 'remove IP...', 'Remove one or more IP blocks'
    long_desc <<-LONG_DESC
      Remove one or more IP blocks. Normally, only exact matches are removed. If
      you want to ensure that all of the given IP addresses are unblocked, you
      can use --force which will also remove any blocks for IP ranges that would
      cover the given IP(s).
    LONG_DESC
    def remove(*addresses)
      fail_with_message 'No IP(s) given' if addresses.empty?

      processed = 0
      skipped   = 0

      addresses.each do |address|
        unless valid_ip_address?(address)
          say("#{address} is invalid", :yellow)
          skipped += 1
          next
        end

        ip_blocks = if options[:force]
                      IpBlock.containing(address)
                    else
                      IpBlock.contained_by(address)
                    end

        if ip_blocks.empty?
          say("#{address} is not yet blocked", :yellow)
          skipped += 1
          next
        end

        ip_blocks.in_batches.destroy_all
        processed += 1
      end

      say("Removed #{processed}, skipped #{skipped}", color(processed, 0))
    end

    option :format, aliases: [:f], enum: %w(plain nginx), desc: 'Format of the output'
    desc 'export', 'Export blocked IPs'
    long_desc <<-LONG_DESC
      Export blocked IPs. Different formats are supported for usage with other
      tools. Only blocks with no_access severity are returned.
    LONG_DESC
    def export
      IpBlock.severity_no_access.find_each do |ip_block|
        case options[:format]
        when 'nginx'
          say "deny #{ip_block.ip}/#{ip_block.ip.prefix};"
        else
          say "#{ip_block.ip}/#{ip_block.ip.prefix}"
        end
      end
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

    def valid_ip_address?(ip_address)
      IPAddr.new(ip_address)
      true
    rescue IPAddr::InvalidAddressError
      false
    end
  end
end
