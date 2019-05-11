# frozen_string_literal: true

require 'concurrent'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class DomainsCLI < Thor
    def self.exit_on_failure?
      true
    end

    option :dry_run, type: :boolean
    desc 'purge DOMAIN', 'Remove accounts from a DOMAIN without a trace'
    long_desc <<-LONG_DESC
      Remove all accounts from a given DOMAIN without leaving behind any
      records. Unlike a suspension, if the DOMAIN still exists in the wild,
      it means the accounts could return if they are resolved again.
    LONG_DESC
    def purge(domain)
      removed = 0
      dry_run = options[:dry_run] ? ' (DRY RUN)' : ''

      Account.where(domain: domain).find_each do |account|
        SuspendAccountService.new.call(account, destroy: true) unless options[:dry_run]
        removed += 1
        say('.', :green, false)
      end

      DomainBlock.where(domain: domain).destroy_all unless options[:dry_run]

      say
      say("Removed #{removed} accounts#{dry_run}", :green)

      custom_emojis = CustomEmoji.where(domain: domain)
      custom_emojis_count = custom_emojis.count
      custom_emojis.destroy_all unless options[:dry_run]
      say("Removed #{custom_emojis_count} custom emojis", :green)
    end

    option :concurrency, type: :numeric, default: 50, aliases: [:c]
    option :silent, type: :boolean, default: false, aliases: [:s]
    option :format, type: :string, default: 'summary', aliases: [:f]
    desc 'crawl [START]', 'Crawl all known peers, optionally beginning at START'
    long_desc <<-LONG_DESC
      Crawl the fediverse by using the Mastodon REST API endpoints that expose
      all known peers, and collect statistics from those peers, as long as those
      peers support those API endpoints. When no START is given, the command uses
      this server's own database of known peers to seed the crawl.

      The --concurrency (-c) option controls the number of threads performing HTTP
      requests at the same time. More threads means the crawl may complete faster.

      The --silent (-s) option controls progress output.

      The --format (-f) option controls how the data is displayed at the end. By
      default (`summary`), a summary of the statistics is returned. The other options
      are `domains`, which returns a newline-delimited list of all discovered peers,
      and `json`, which dumps all the aggregated data raw.
    LONG_DESC
    def crawl(start = nil)
      stats     = Concurrent::Hash.new
      processed = Concurrent::AtomicFixnum.new(0)
      failed    = Concurrent::AtomicFixnum.new(0)
      start_at  = Time.now.to_f
      seed      = start ? [start] : Account.remote.domains

      pool = Concurrent::ThreadPoolExecutor.new(min_threads: 0, max_threads: options[:concurrency], idletime: 10, auto_terminate: true, max_queue: 0)

      work_unit = ->(domain) do
        next if stats.key?(domain)
        stats[domain] = nil
        processed.increment

        begin
          Request.new(:get, "https://#{domain}/api/v1/instance").perform do |res|
            next unless res.code == 200
            stats[domain] = Oj.load(res.to_s)
          end

          Request.new(:get, "https://#{domain}/api/v1/instance/peers").perform do |res|
            next unless res.code == 200

            Oj.load(res.to_s).reject { |peer| stats.key?(peer) }.each do |peer|
              pool.post(peer, &work_unit)
            end
          end

          Request.new(:get, "https://#{domain}/api/v1/instance/activity").perform do |res|
            next unless res.code == 200
            stats[domain]['activity'] = Oj.load(res.to_s)
          end

          say('.', :green, false) unless options[:silent]
        rescue StandardError
          failed.increment
          say('.', :red, false) unless options[:silent]
        end
      end

      seed.each do |domain|
        pool.post(domain, &work_unit)
      end

      sleep 20
      sleep 20 until pool.queue_length.zero?

      pool.shutdown
      pool.wait_for_termination(20)
    ensure
      pool.shutdown

      say unless options[:silent]

      case options[:format]
      when 'summary'
        stats_to_summary(stats, processed, failed, start_at)
      when 'domains'
        stats_to_domains(stats)
      when 'json'
        stats_to_json(stats)
      end
    end

    private

    def stats_to_summary(stats, processed, failed, start_at)
      stats.compact!

      total_domains = stats.size
      total_users   = stats.reduce(0) { |sum, (_key, val)| val.is_a?(Hash) && val['stats'].is_a?(Hash) ? sum + val['stats']['user_count'].to_i : sum }
      total_active  = stats.reduce(0) { |sum, (_key, val)| val.is_a?(Hash) && val['activity'].is_a?(Array) && val['activity'].size > 2 && val['activity'][1].is_a?(Hash) ? sum + val['activity'][1]['logins'].to_i : sum }
      total_joined  = stats.reduce(0) { |sum, (_key, val)| val.is_a?(Hash) && val['activity'].is_a?(Array) && val['activity'].size > 2 && val['activity'][1].is_a?(Hash) ? sum + val['activity'][1]['registrations'].to_i : sum }

      say("Visited #{processed.value} domains, #{failed.value} failed (#{(Time.now.to_f - start_at).round}s elapsed)", :green)
      say("Total servers: #{total_domains}", :green)
      say("Total registered: #{total_users}", :green)
      say("Total active last week: #{total_active}", :green)
      say("Total joined last week: #{total_joined}", :green)
    end

    def stats_to_domains(stats)
      say(stats.keys.join("\n"))
    end

    def stats_to_json(stats)
      stats.compact!
      say(Oj.dump(stats))
    end
  end
end
