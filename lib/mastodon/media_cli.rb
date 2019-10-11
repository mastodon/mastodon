# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class MediaCLI < Thor
    include ActionView::Helpers::NumberHelper
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    option :days, type: :numeric, default: 7, aliases: [:d]
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, default: false, aliases: [:v]
    option :dry_run, type: :boolean, default: false
    desc 'remove', 'Remove remote media files'
    long_desc <<-DESC
      Removes locally cached copies of media attachments from other servers.

      The --days option specifies how old media attachments have to be before
      they are removed. It defaults to 7 days.
    DESC
    def remove
      time_ago = options[:days].days.ago
      dry_run  = options[:dry_run] ? '(DRY RUN)' : ''

      processed, aggregate = parallelize_with_progress(MediaAttachment.cached.where.not(remote_url: '').where('created_at < ?', time_ago)) do |media_attachment|
        next if media_attachment.file.blank?

        size = media_attachment.file_file_size

        unless options[:dry_run]
          media_attachment.file.destroy
          media_attachment.save
        end

        size
      end

      say("Removed #{processed} media attachments (approx. #{number_to_human_size(aggregate)}) #{dry_run}", :green, true)
    end

    option :account, type: :string
    option :domain, type: :string
    option :status, type: :numeric
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, default: false, aliases: [:v]
    option :dry_run, type: :boolean, default: false
    option :force, type: :boolean, default: false
    desc 'refresh', 'Fetch remote media files'
    long_desc <<-DESC
      Re-downloads media attachments from other servers. You must specify the
      source of media attachments with one of the following options:

      Use the --status option to download attachments from a specific status,
      using the status local numeric ID.

      Use the --account option to download attachments from a specific account,
      using username@domain handle of the account.

      Use the --domain option to download attachments from a specific domain.

      By default, attachments that are believed to be already downloaded will
      not be re-downloaded. To force re-download of every URL, use --force.
    DESC
    def refresh
      dry_run = options[:dry_run] ? ' (DRY RUN)' : ''

      if options[:status]
        scope = MediaAttachment.where(status_id: options[:status])
      elsif options[:account]
        username, domain = username.split('@')
        account = Account.find_remote(username, domain)

        if account.nil?
          say('No such account', :red)
          exit(1)
        end

        scope = MediaAttachment.where(account_id: account.id)
      elsif options[:domain]
        scope = MediaAttachment.joins(:account).merge(Account.by_domain_and_subdomains(options[:domain]))
      else
        exit(1)
      end

      processed, aggregate = parallelize_with_progress(scope) do |media_attachment|
        next if media_attachment.remote_url.blank? || (!options[:force] && media_attachment.file_file_name.present?)

        unless options[:dry_run]
          media_attachment.reset_file!
          media_attachment.save
        end

        media_attachment.file_file_size
      end

      say("Downloaded #{processed} media attachments (approx. #{number_to_human_size(aggregate)})#{dry_run}", :green, true)
    end

    desc 'usage', 'Calculate disk space consumed by Mastodon'
    def usage
      say("Attachments:\t#{number_to_human_size(MediaAttachment.sum(:file_file_size))} (#{number_to_human_size(MediaAttachment.where(account: Account.local).sum(:file_file_size))} local)")
      say("Custom emoji:\t#{number_to_human_size(CustomEmoji.sum(:image_file_size))} (#{number_to_human_size(CustomEmoji.local.sum(:image_file_size))} local)")
      say("Preview cards:\t#{number_to_human_size(PreviewCard.sum(:image_file_size))}")
      say("Avatars:\t#{number_to_human_size(Account.sum(:avatar_file_size))} (#{number_to_human_size(Account.local.sum(:avatar_file_size))} local)")
      say("Headers:\t#{number_to_human_size(Account.sum(:header_file_size))} (#{number_to_human_size(Account.local.sum(:header_file_size))} local)")
      say("Backups:\t#{number_to_human_size(Backup.sum(:dump_file_size))}")
      say("Imports:\t#{number_to_human_size(Import.sum(:data_file_size))}")
      say("Settings:\t#{number_to_human_size(SiteUpload.sum(:file_file_size))}")
    end
  end
end
