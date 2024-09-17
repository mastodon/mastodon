# frozen_string_literal: true

require 'rubygems/package'
require_relative 'base'

module Mastodon::CLI
  class Emoji < Base
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

      You can specify a --category under which the emojis will be
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
          next unless entry.file? && entry.full_name.end_with?('.png', '.gif')

          filename = File.basename(entry.full_name, '.*')

          # Skip macOS shadow files
          next if filename.start_with?('._')

          shortcode    = [options[:prefix], filename, options[:suffix]].compact.join
          custom_emoji = CustomEmoji.local.find_by('LOWER(shortcode) = ?', shortcode.downcase)

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
            shell.indent(2) do
              say(custom_emoji.errors[:image].join(', '), :red)
            end
          end
        end
      end

      say("Imported #{imported}, skipped #{skipped}, failed to import #{failed}", color(imported, skipped, failed))
    end

    option :category
    option :overwrite, type: :boolean
    desc 'export PATH', 'Export emoji to a TAR GZIP archive at PATH'
    long_desc <<-LONG_DESC
      Exports custom emoji to 'export.tar.gz' at PATH.

      The --category option dumps only the specified category.
      If this option is not specified, all emoji will be exported.

      The --overwrite option will overwrite an existing archive.
    LONG_DESC
    def export(path)
      exported         = 0
      category         = CustomEmojiCategory.find_by(name: options[:category])
      export_file_name = File.join(path, 'export.tar.gz')

      fail_with_message "Archive already exists! Use '--overwrite' to overwrite it!" if File.file?(export_file_name) && !options[:overwrite]
      fail_with_message "Unable to find category '#{options[:category]}'!" if category.nil? && options[:category]

      File.open(export_file_name, 'wb') do |file|
        Zlib::GzipWriter.wrap(file) do |gzip|
          Gem::Package::TarWriter.new(gzip) do |tar|
            scope = !options[:category] || category.nil? ? CustomEmoji.local : category.emojis
            scope.find_each do |emoji|
              say("Adding '#{emoji.shortcode}'...")
              tar.add_file_simple(emoji.shortcode + File.extname(emoji.image_file_name), 0o644, emoji.image_file_size) do |io|
                io.write Paperclip.io_adapters.for(emoji.image).read
                exported += 1
              end
            end
          end
        end
      end
      say("Exported #{exported}")
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
