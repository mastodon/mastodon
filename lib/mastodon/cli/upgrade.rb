# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Upgrade < Base
    CURRENT_STORAGE_SCHEMA_VERSION = 1

    option :dry_run, type: :boolean, default: false
    option :verbose, type: :boolean, default: false, aliases: [:v]
    desc 'storage-schema', 'Upgrade storage schema of various file attachments to the latest version'
    long_desc <<~LONG_DESC
      Iterates over every file attachment of every record and, if its storage schema is outdated, performs the
      necessary upgrade to the latest one. In practice this means e.g. moving files to different directories.

      Will most likely take a long time.
    LONG_DESC
    def storage_schema
      progress = create_progress_bar(nil)
      records  = 0

      klasses = [
        Account,
        CustomEmoji,
        MediaAttachment,
        PreviewCard,
      ]

      klasses.each do |klass|
        attachment_names = klass.attachment_definitions.keys

        klass.find_each do |record|
          attachment_names.each do |attachment_name|
            attachment = record.public_send(attachment_name)
            upgraded   = false

            next if attachment.blank? || attachment.storage_schema_version >= CURRENT_STORAGE_SCHEMA_VERSION

            styles = attachment.styles.keys

            styles << :original unless styles.include?(:original)

            styles.each do |style|
              success = case Paperclip::Attachment.default_options[:storage]
                        when :s3
                          upgrade_storage_s3(progress, attachment, style)
                        when :fog
                          upgrade_storage_fog(progress, attachment, style)
                        when :azure
                          upgrade_storage_azure(progress, attachment, style)
                        when :filesystem
                          upgrade_storage_filesystem(progress, attachment, style)
                        end

              upgraded = true if style == :original && success

              progress.increment
            end

            attachment.instance_write(:storage_schema_version, CURRENT_STORAGE_SCHEMA_VERSION) if upgraded
          end

          if record.changed?
            record.save unless dry_run?
            records += 1
          end
        end
      end

      progress.total = progress.progress
      progress.finish

      say("Upgraded storage schema of #{records} records#{dry_run_mode_suffix}", :green, true)
    end

    private

    def upgrade_storage_s3(progress, attachment, style)
      previous_storage_schema_version = attachment.storage_schema_version
      object                          = attachment.s3_object(style)
      success                         = true

      attachment.instance_write(:storage_schema_version, CURRENT_STORAGE_SCHEMA_VERSION)

      new_object = attachment.s3_object(style)

      if new_object.key != object.key && object.exists?
        progress.log("Moving #{object.key} to #{new_object.key}") if options[:verbose]

        begin
          object.move_to(new_object, acl: attachment.s3_permissions(style)) unless dry_run?
        rescue => e
          progress.log(pastel.red("Error processing #{object.key}: #{e}"))
          success = false
        end
      end

      # Because we move files style-by-style, it's important to restore
      # previous version at the end. The upgrade will be recorded after
      # all styles are updated
      attachment.instance_write(:storage_schema_version, previous_storage_schema_version)
      success
    end

    def upgrade_storage_fog(_progress, _attachment, _style)
      say('The fog storage driver is not supported for this operation at this time', :red)
      exit(1)
    end

    def upgrade_storage_azure(_progress, _attachment, _style)
      say('The azure storage driver is not supported for this operation at this time', :red)
      exit(1)
    end

    def upgrade_storage_filesystem(progress, attachment, style)
      previous_storage_schema_version = attachment.storage_schema_version
      previous_path                   = attachment.path(style)
      success                         = true

      attachment.instance_write(:storage_schema_version, CURRENT_STORAGE_SCHEMA_VERSION)

      upgraded_path = attachment.path(style)

      if upgraded_path != previous_path && File.exist?(previous_path)
        progress.log("Moving #{previous_path} to #{upgraded_path}") if options[:verbose]

        begin
          unless dry_run?
            FileUtils.mkdir_p(File.dirname(upgraded_path))
            FileUtils.mv(previous_path, upgraded_path)

            begin
              FileUtils.rmdir(File.dirname(previous_path), parents: true)
            rescue Errno::ENOTEMPTY
              # OK
            end
          end
        rescue => e
          progress.log(pastel.red("Error processing #{previous_path}: #{e}"))
          success = false

          unless dry_run?
            begin
              FileUtils.rmdir(File.dirname(upgraded_path), parents: true)
            rescue Errno::ENOTEMPTY
              # OK
            end
          end
        end
      end

      # Because we move files style-by-style, it's important to restore
      # previous version at the end. The upgrade will be recorded after
      # all styles are updated
      attachment.instance_write(:storage_schema_version, previous_storage_schema_version)
      success
    end
  end
end
