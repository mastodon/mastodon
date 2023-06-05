# frozen_string_literal: true

require 'tty-prompt'
require_relative 'base'

module Mastodon::CLI
  class PreviewCards < Base
    include ActionView::Helpers::NumberHelper

    option :days, type: :numeric, default: 180
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    option :dry_run, type: :boolean, default: false
    option :link, type: :boolean, default: false
    desc 'remove', 'Remove preview cards'
    long_desc <<-DESC
      Removes local thumbnails for preview cards.

      The --days option specifies how old preview cards have to be before
      they are removed. It defaults to 180 days. Since preview cards will
      not be re-fetched unless the link is re-posted after 2 weeks from
      last time, it is not recommended to delete preview cards within the
      last 14 days.

      With the --link option, only link-type preview cards will be deleted,
      leaving video and photo cards untouched.
    DESC
    def remove
      time_ago = options[:days].days.ago
      link     = options[:link] ? 'link-type ' : ''
      scope    = PreviewCard.cached
      scope    = scope.where(type: :link) if options[:link]
      scope    = scope.where('updated_at < ?', time_ago)

      processed, aggregate = parallelize_with_progress(scope) do |preview_card|
        next if preview_card.image.blank?

        size = preview_card.image_file_size

        unless dry_run?
          preview_card.image.destroy
          preview_card.save
        end

        size
      end

      say("Removed #{processed} #{link}preview cards (approx. #{number_to_human_size(aggregate)})#{dry_run_mode_suffix}", :green, true)
    end
  end
end
