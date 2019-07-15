# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class PreviewCardsCLI < Thor
    include ActionView::Helpers::NumberHelper

    def self.exit_on_failure?
      true
    end

    option :days, type: :numeric, default: 180
    option :background, type: :boolean, default: false
    option :verbose, type: :boolean, default: false
    option :dry_run, type: :boolean, default: false
    option :link, type: :boolean, default: false
    desc 'remove', 'Remove preview cards'
    long_desc <<-DESC
      Removes locally thumbnails for previews.

      The --days option specifies how old preview cards have to be before
      they are removed. It defaults to 180 days.

      With the --background option, instead of deleting the files sequentially,
      they will be queued into Sidekiq and the command will exit as soon as
      possible. In Sidekiq they will be processed with higher concurrency, but
      it may impact other operations of the Mastodon server, and it may overload
      the underlying file storage.

      With the --dry-run option, no work will be done.

      With the --verbose option, when preview cards are processed sequentially in the
      foreground, the IDs of the preview cards will be printed.

      With the --link option, delete only link-type preview cards.
    DESC
    def remove
      time_ago  = options[:days].days.ago
      queued    = 0
      processed = 0
      size      = 0
      dry_run   = options[:dry_run] ? '(DRY RUN)' : ''

      if options[:link] && options[:background]
        PreviewCard.where.not(image_file_name: nil).where(type: :link).where('updated_at < ?', time_ago).select(:id, :image_file_size).reorder(nil).find_in_batches do |preview_cards|
          queued += preview_cards.size
          size   += preview_cards.reduce(0) { |sum, p| sum + (p.image_file_size || 0) }
          Maintenance::UncachePreviewWorker.push_bulk(preview_cards.map(&:id)) unless options[:dry_run]
        end

      elsif options[:link] && !options[:background]
        PreviewCard.where.not(image_file_name: nil).where(type: :link).where('updated_at < ?', time_ago).select(:id, :image_file_size).reorder(nil).find_in_batches do |preview_cards|
          preview_cards.each do |p|
            size += p.image_file_size || 0
            Maintenance::UncachePreviewWorker.new.perform(p.id) unless options[:dry_run]
            options[:verbose] ? say(p.id) : say('.', :green, false)
            processed += 1
          end
        end

      elsif !options[:link] && options[:background]
        PreviewCard.where.not(image_file_name: nil).where('updated_at < ?', time_ago).select(:id, :image_file_size).reorder(nil).find_in_batches do |preview_cards|
          queued += preview_cards.size
          size   += preview_cards.reduce(0) { |sum, p| sum + (p.image_file_size || 0) }
          Maintenance::UncachePreviewWorker.push_bulk(preview_cards.map(&:id)) unless options[:dry_run]
        end

      else
        PreviewCard.where.not(image_file_name: nil).where('updated_at < ?', time_ago).select(:id, :image_file_size).reorder(nil).find_in_batches do |preview_cards|
          preview_cards.each do |p|
            size += p.image_file_size || 0
            Maintenance::UncachePreviewWorker.new.perform(p.id) unless options[:dry_run]
            options[:verbose] ? say(p.id) : say('.', :green, false)
            processed += 1
          end
        end
      end

      say

      if options[:background]
        say("Scheduled the deletion of #{queued} preview cards (approx. #{number_to_human_size(size)}) #{dry_run}", :green, true)
      else
        say("Removed #{processed} preview cards (approx. #{number_to_human_size(size)}) #{dry_run}", :green, true)
      end
    end
  end
end
