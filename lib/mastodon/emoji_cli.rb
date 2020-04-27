# frozen_string_literal: true

require 'rubygems/package'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class EmojiCLI < Thor
    def self.exit_on_failure?
      true
    end

    option :prefix
    option :suffix
    option :overwrite, type: :boolean
    option :unlisted, type: :boolean
    option :category
    desc 'import PATH', 'Import emoji from a TAR GZIP archive at PATH'
    long_desc <<-LONG_DESC
      Imports custom emoji from a TAR GZIP archive specified by PATH.

      Existing emoji will be skipped unless the --overwrite option
      is provided, in which case they will be overwritten.

      You can specifiy a --category under which the emojis will be
      grouped together.

      With the --prefix option, a prefix can be added to all
      generated shortcodes. Likewise, the --suffix option controls
      the suffix of all shortcodes.

      With the --unlisted option, the processed emoji will not be
      visible in the emoji picker (but still usable via other means)
    LONG_DESC
    def import(path)
      imported = 0
      skipped  = 0
      failed   = 0
      category = options[:category] ? CustomEmojiCategory.find_or_create_by(name: options[:category]) : nil

      Gem::Package::TarReader.new(Zlib::GzipReader.open(path)) do |tar|
        tar.each do |entry|
          next unless entry.file? && entry.full_name.end_with?('.png')

          shortcode    = [options[:prefix], File.basename(entry.full_name, '.*'), options[:suffix]].compact.join
          custom_emoji = CustomEmoji.local.find_by(shortcode: shortcode)

          if custom_emoji && !options[:overwrite]
            skipped += 1
            next
          end

          custom_emoji ||= CustomEmoji.new(shortcode: shortcode, domain: nil)
          custom_emoji.image = StringIO.new(entry.read)
          custom_emoji.image_file_name = File.basename(entry.full_name)
          custom_emoji.visible_in_picker = !options[:unlisted]
          custom_emoji.category = category

          if custom_emoji.save
            imported += 1
          else
            failed += 1
            say('Failure/Error: ', :red)
            say(entry.full_name)
            say('    ' + custom_emoji.errors[:image].join(', '), :red)
          end
        end
      end

      puts
      say("Imported #{imported}, skipped #{skipped}, failed to import #{failed}", color(imported, skipped, failed))
    end

    option :remote_only, type: :boolean
    desc 'purge', 'Remove all custom emoji'
    long_desc <<-LONG_DESC
      Removes all custom emoji.

      With the --remote-only option, only remote emoji will be deleted.
    LONG_DESC
    def purge
      scope = options[:remote_only] ? CustomEmoji.remote : CustomEmoji
      scope.in_batches.destroy_all
      say('OK', :green)
    end

    private

    def color(green, _yellow, red)
      if !green.zero? && red.zero?
        :green
      elsif red.zero?
        :yellow
      else
        :red
      end
    end
  end
end
