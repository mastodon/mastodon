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
  end
end
