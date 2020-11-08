# frozen_string_literal: true

require 'concurrent'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class DomainsCLI < Thor
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    option :dry_run, type: :boolean
    option :limited_federation_mode, type: :boolean
    desc 'purge [DOMAIN...]', 'Remove accounts from a DOMAIN without a trace'
    long_desc <<-LONG_DESC
      Remove all accounts from a given DOMAIN without leaving behind any
      records. Unlike a suspension, if the DOMAIN still exists in the wild,
      it means the accounts could return if they are resolved again.

      When the --limited-federation-mode option is given, instead of purging accounts
      from a single domain, all accounts from domains that have not been explicitly allowed
      are removed from the database.
    LONG_DESC
    def purge(*domains)
      dry_run = options[:dry_run] ? ' (DRY RUN)' : ''

      scope = begin
        if options[:limited_federation_mode]
          Account.remote.where.not(domain: DomainAllow.pluck(:domain))
        elsif !domains.empty?
          Account.remote.where(domain: domains)
        else
          say('No domain(s) given', :red)
          exit(1)
        end
      end

      processed, = parallelize_with_progress(scope) do |account|
        DeleteAccountService.new.call(account, reserve_username: false, skip_side_effects: true) unless options[:dry_run]
      end

      DomainBlock.where(domain: domains).destroy_all unless options[:dry_run]

      say("Removed #{processed} accounts#{dry_run}", :green)

      custom_emojis = CustomEmoji.where(domain: domains)
      custom_emojis_count = custom_emojis.count
      custom_emojis.destroy_all unless options[:dry_run]

      say("Removed #{custom_emojis_count} custom emojis", :green)
    end

    option :concurrency, type: :numeric, default: 50, aliases: [:c]
    option :format, type: :string, default: 'summary', aliases: [:f]
    option :exclude_suspended, type: :boolean, default: false, aliases: [:x]
    desc 'crawl [START]', 'Crawl all known peers, optionally beginning at START'
    long_desc <<-LONG_DESC
      Crawl the fediverse by using the Mastodon REST API endpoints that expose
      all known peers, and collect statistics from those peers, as long as those
      peers support those API endpoints. When no START is given, the command uses
      this server's own database of known peers to seed the crawl.

      The --concurrency (-c) option controls the number of threads performing HTTP
      requests at the same time. More threads means the crawl may complete faster.

      The --format (-f) option controls how the data is displayed at the end. By
      default (`summary`), a summary of the statistics is returned. The other options
      are `domains`, which returns a newline-delimited list of all discovered peers,
      and `json`, which dumps all the aggregated data raw.

      The --exclude-suspended (-x) option means that domains that are suspended
      instance-wide do not appear in the output and are not included in summaries.
      This also excludes subdomains of any of those domains.
    LONG_DESC
    def crawl(start = nil)
      stats           = Concurrent::Hash.new
      processed       = Concurrent::AtomicFixnum.new(0)
      failed          = Concurrent::AtomicFixnum.new(0)
      start_at        = Time.now.to_f
      seed            = start ? [start] : Account.remote.domains
      blocked_domains = Regexp.new('\\.?' + DomainBlock.where(severity: 1).pluck(:domain).join('|') + '$')
      progress        = create_progress_bar

      pool = Concurrent::ThreadPoolExecutor.new(min_threads: 0, max_threads: options[:concurrency], idletime: 10, auto_terminate: true, max_queue: 0)

      work_unit = ->(domain) do
        next if stats.key?(domain)
        next if options[:exclude_suspended] && domain.match(blocked_domains)

        stats[domain] = nil

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
        rescue StandardError
          failed.increment
        ensure
          processed.increment
          progress.increment unless progress.finished?
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
      progress.finish
      pool.shutdown

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
