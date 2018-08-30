# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

# rubocop:disable Rails/Output

module Mastodon
  class MediaCLI < Thor
    option :days, type: :numeric, default: 7
    option :background, type: :boolean, default: false
    desc 'remove', 'Remove remote media files'
    long_desc <<-DESC
      Removes locally cached copies of media attachments from other servers.

      The --days option specifies how old media attachments have to be before
      they are removed. It defaults to 7 days.

      With the --background option, instead of deleting the files sequentially,
      they will be queued into Sidekiq and the command will exit as soon as
      possible. In Sidekiq they will be processed with higher concurrency, but
      it may impact other operations of the Mastodon server, and it may overload
      the underlying file storage.
    DESC
    def remove
      time_ago  = options[:days].days.ago
      queued    = 0
      processed = 0

      if options[:background]
        MediaAttachment.where.not(remote_url: '').where.not(file_file_name: nil).where('created_at < ?', time_ago).select(:id).reorder(nil).find_in_batches do |media_attachments|
          queued += media_attachments.size
          Maintenance::UncacheMediaWorker.push_bulk(media_attachments.map(&:id))
        end
      else
        MediaAttachment.where.not(remote_url: '').where.not(file_file_name: nil).where('created_at < ?', time_ago).reorder(nil).find_in_batches do |media_attachments|
          media_attachments.each do |m|
            Maintenance::UncacheMediaWorker.new.perform(m)
            say('.', :green, false)
            processed += 1
          end
        end
      end

      say

      if options[:background]
        say("Scheduled the deletion of #{queued} media attachments", :green)
      else
        say("Removed #{processed} media attachments", :green)
      end
    end
  end
end

# rubocop:enable Rails/Output
