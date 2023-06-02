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
      processed, aggregate = parallelize_with_progress(preview_card_scope) do |preview_card|
        next if preview_card.image.blank?

        preview_card.image_file_size.tap do
          process_preview_card(preview_card)
        end
      end

      say(summary_message(processed, aggregate), :green, true)
    end

    private

    def time_ago
      options[:days].days.ago
    end

    def link_option?
      options[:link].present?
    end

    def link_type_s
      link_option? ? 'link-type ' : ''
    end

    def preview_card_scope
      PreviewCard.cached.tap do |scope|
        scope.merge!(link_type_scope) if link_option?
        scope.merge!(time_ago_scope)
      end
    end

    def link_type_scope
      PreviewCard.where(type: :link)
    end

    def time_ago_scope
      PreviewCard.where('updated_at < ?', time_ago)
    end

    def process_preview_card(preview_card)
      return if dry_run?

      preview_card.image.destroy
      preview_card.save
    end

    def summary_message(count, file_size)
      "Removed #{count} #{link_type_s}preview cards (approx. #{number_to_human_size(file_size)})#{dry_run_mode_suffix}"
    end
  end
end
