# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Cleanup < Base
    include ActionView::Helpers::NumberHelper

    option :domain, type: :string
    option :suspended_instances, type: :boolean
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :dry_run, type: :boolean
    desc 'accounts', 'Clean up suspended/domain-specific, accounts, posts, and media from DB and S3'
    long_desc <<-LONG_DESC
      Clean up accounts and remove all evidence of those accounts, their posts, and their media from DB and S3.

      With the --domain DOMAIN option, all remote accounts from a specific domain will be purged.
      With the --suspended-instances option, all remote accounts from suspended instances will be purged.
    LONG_DESC
    def accounts
      unless options[:domain].present? || options[:suspended_instances]
        fail_with_message 'Please specify at least one cleanup category (--domain, --suspended-instances)'
      end

      target_domain = options[:domain].present? ? TagManager.instance.normalize_domain(options[:domain].to_s.strip) : nil
      scopes = []

      if target_domain.present?
        scopes << Account.remote.with_domain(target_domain)
      end

      if options[:suspended_instances] || options[:all]
        domain_scope = DomainBlock.suspend.select(:domain)
        domain_scope = domain_scope.where('lower(domain) = lower(?)', target_domain) if target_domain.present?
        scopes << Account.remote.where(domain: domain_scope)
      end

      combined_scope = scopes.reduce(:or).without_instance_actor

      progress = create_progress_bar(combined_scope.count)
      total_deleted = 0
      total_statuses = 0
      total_media_count = 0
      total_media_bytes = 0

      combined_scope.find_each do |account|
        acct = account.acct
        statuses_count = account.statuses.count
        media_attachments = account.media_attachments
        media_count = media_attachments.count
        media_bytes = media_attachments.sum(MediaAttachment.combined_media_file_size)

        formatted_size = number_to_human_size(media_bytes)

        if dry_run?
          progress.log("Would delete @#{acct}: #{statuses_count} statuses, #{media_count} media attachments (#{formatted_size})")
        else
          begin
            DeleteAccountService.new.call(account, reserve_username: false, reserve_email: false, skip_side_effects: true)
            progress.log(pastel.green("Deleted @#{acct}: #{statuses_count} statuses, #{media_count} media attachments (#{formatted_size})"))
          rescue => e
            progress.log(pastel.red("Failed to delete @#{acct}: #{e.message}"))
            next
          end
        end

        total_deleted += 1
        total_statuses += statuses_count
        total_media_count += media_count
        total_media_bytes += media_bytes
        progress.increment
      end

      progress.finish

      say(
        "OK, cleaned up #{total_deleted} accounts, #{total_statuses} statuses, #{total_media_count} media attachments (approx. #{number_to_human_size(total_media_bytes)})#{dry_run_mode_suffix}",
        :green
      )
    end
  end
end
