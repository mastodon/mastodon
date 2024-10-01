# frozen_string_literal: true

require 'concurrent'
require_relative 'base'

module Mastodon::CLI
  class Domains < Base
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    option :dry_run, type: :boolean
    option :limited_federation_mode, type: :boolean
    option :by_uri, type: :boolean
    option :include_subdomains, type: :boolean
    option :purge_domain_blocks, type: :boolean
    desc 'purge [DOMAIN...]', 'Remove accounts from a DOMAIN without a trace'
    long_desc <<-LONG_DESC
      Remove all accounts from a given DOMAIN without leaving behind any
      records. Unlike a suspension, if the DOMAIN still exists in the wild,
      it means the accounts could return if they are resolved again.

      When the --limited-federation-mode option is given, instead of purging accounts
      from a single domain, all accounts from domains that have not been explicitly allowed
      are removed from the database.

      When the --by-uri option is given, DOMAIN is used to match the domain part of actor
      URIs rather than the domain part of the webfinger handle. For instance, an account
      that has the handle `foo@bar.com` but whose profile is at the URL
      `https://mastodon-bar.com/users/foo`, would be purged by either
      `tootctl domains purge bar.com` or `tootctl domains purge --by-uri mastodon-bar.com`.

      When the --include-subdomains option is given, not only DOMAIN is deleted, but all
      subdomains as well. Note that this may be considerably slower.

      When the --purge-domain-blocks option is given, also purge matching domain blocks.
    LONG_DESC
    def purge(*domains)
      domains            = domains.map { |domain| TagManager.instance.normalize_domain(domain) }
      account_scope      = Account.none
      domain_block_scope = DomainBlock.none
      emoji_scope        = CustomEmoji.none

      # Sanity check on command arguments
      if options[:limited_federation_mode] && !domains.empty?
        fail_with_message 'DOMAIN parameter not supported with --limited-federation-mode'
      elsif domains.empty? && !options[:limited_federation_mode]
        fail_with_message 'No domain(s) given'
      end

      # Build scopes from command arguments
      if options[:limited_federation_mode]
        account_scope = Account.remote.where.not(domain: DomainAllow.select(:domain))
        emoji_scope   = CustomEmoji.remote.where.not(domain: DomainAllow.select(:domain))
      else
        # Handle wildcard subdomains
        subdomain_patterns = domains.filter_map { |domain| "%.#{Account.sanitize_sql_like(domain[2..])}" if domain.start_with?('*.') }
        domains = domains.filter { |domain| !domain.start_with?('*.') }
        # Handle --include-subdomains
        subdomain_patterns += domains.map { |domain| "%.#{Account.sanitize_sql_like(domain)}" } if options[:include_subdomains]
        uri_patterns = (domains.map { |domain| Account.sanitize_sql_like(domain) } + subdomain_patterns).map { |pattern| "https://#{pattern}/%" }

        if options[:purge_domain_blocks]
          domain_block_scope = DomainBlock.where(domain: domains)
          domain_block_scope = domain_block_scope.or(DomainBlock.where(DomainBlock.arel_table[:domain].matches_any(subdomain_patterns))) unless subdomain_patterns.empty?
        end

        if options[:by_uri]
          account_scope = Account.remote.where(Account.arel_table[:uri].matches_any(uri_patterns, false, true))
          emoji_scope   = CustomEmoji.remote.where(CustomEmoji.arel_table[:uri].matches_any(uri_patterns, false, true))
        else
          account_scope = Account.remote.where(domain: domains)
          account_scope = account_scope.or(Account.remote.where(Account.arel_table[:domain].matches_any(subdomain_patterns))) unless subdomain_patterns.empty?
          emoji_scope   = CustomEmoji.where(domain: domains)
          emoji_scope   = emoji_scope.or(CustomEmoji.remote.where(CustomEmoji.arel_table[:uri].matches_any(subdomain_patterns))) unless subdomain_patterns.empty?
        end
      end

      # Actually perform the deletions
      processed, = parallelize_with_progress(account_scope) do |account|
        DeleteAccountService.new.call(account, reserve_username: false, skip_side_effects: true) unless dry_run?
      end

      say("Removed #{processed} accounts#{dry_run_mode_suffix}", :green)

      if options[:purge_domain_blocks]
        domain_block_count = domain_block_scope.count
        domain_block_scope.in_batches.destroy_all unless dry_run?
        say("Removed #{domain_block_count} domain blocks#{dry_run_mode_suffix}", :green)
      end

      custom_emojis_count = emoji_scope.count
      emoji_scope.in_batches.destroy_all unless dry_run?

      Instance.refresh unless dry_run?

      say("Removed #{custom_emojis_count} custom emojis#{dry_run_mode_suffix}", :green)
    end

    CRAWL_SLEEP_TIME = 20

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
      seed            = start ? [start] : Instance.pluck(:domain)
      blocked_domains = /\.?(#{Regexp.union(domain_block_suspended_domains).source})$/
      progress        = create_progress_bar

      pool = Concurrent::ThreadPoolExecutor.new(min_threads: 0, max_threads: options[:concurrency], idletime: 10, auto_terminate: true, max_queue: 0)

      work_unit = lambda do |domain|
        next if stats.key?(domain)
        next if options[:exclude_suspended] && domain.match?(blocked_domains)

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
        rescue
          failed.increment
        ensure
          processed.increment
          progress.increment unless progress.finished?
        end
      end

      seed.each do |domain|
        pool.post(domain, &work_unit)
      end

      sleep CRAWL_SLEEP_TIME
      sleep CRAWL_SLEEP_TIME until pool.queue_length.zero?

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

    def domain_block_suspended_domains
      DomainBlock.suspend.pluck(:domain)
    end

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
