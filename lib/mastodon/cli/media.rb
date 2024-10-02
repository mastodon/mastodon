# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Media < Base
    include ActionView::Helpers::NumberHelper

    VALID_PATH_SEGMENTS_SIZE = [7, 10].freeze

    option :days, type: :numeric, default: 7, aliases: [:d]
    option :prune_profiles, type: :boolean, default: false
    option :remove_headers, type: :boolean, default: false
    option :include_follows, type: :boolean, default: false
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, default: false, aliases: [:v]
    option :dry_run, type: :boolean, default: false
    desc 'remove', 'Remove remote media files, headers or avatars'
    long_desc <<-DESC
      Removes locally cached copies of media attachments (and optionally profile
      headers and avatars) from other servers. By default, only media attachments
      are removed.
      The --days option specifies how old media attachments have to be before
      they are removed. In case of avatars and headers, it specifies how old
      the last webfinger request and update to the user has to be before they
      are pruned. It defaults to 7 days.
      If --prune-profiles is specified, only avatars and headers are removed.
      If --remove-headers is specified, only headers are removed.
      If --include-follows is specified along with --prune-profiles or
      --remove-headers, all non-local profiles will be pruned irrespective of
      follow status. By default, only accounts that are not followed by or
      following anyone locally are pruned.
    DESC
    def remove
      fail_with_message '--prune-profiles and --remove-headers should not be specified simultaneously' if options[:prune_profiles] && options[:remove_headers]

      fail_with_message '--include-follows can only be used with --prune-profiles or --remove-headers' if options[:include_follows] && !(options[:prune_profiles] || options[:remove_headers])
      time_ago = options[:days].days.ago

      if options[:prune_profiles] || options[:remove_headers]
        processed, aggregate = parallelize_with_progress(Account.remote.where({ last_webfingered_at: ..time_ago, updated_at: ..time_ago })) do |account|
          next if !options[:include_follows] && Follow.where(account: account).or(Follow.where(target_account: account)).exists?
          next if account.avatar.blank? && account.header.blank?
          next if options[:remove_headers] && account.header.blank?

          size = account.header_file_size || 0
          size += account.avatar_file_size || 0 if options[:prune_profiles]

          unless dry_run?
            account.header.destroy
            account.avatar.destroy if options[:prune_profiles]
            account.save!
          end

          size
        end

        say("Visited #{processed} accounts and removed profile media totaling #{number_to_human_size(aggregate)}#{dry_run_mode_suffix}", :green, true)
      end

      unless options[:prune_profiles] || options[:remove_headers]
        processed, aggregate = parallelize_with_progress(MediaAttachment.cached.remote.where(created_at: ..time_ago)) do |media_attachment|
          next if media_attachment.file.blank?

          size = (media_attachment.file_file_size || 0) + (media_attachment.thumbnail_file_size || 0)

          unless dry_run?
            media_attachment.file.destroy
            media_attachment.thumbnail.destroy
            media_attachment.save
          end

          size
        end

        say("Removed #{processed} media attachments (approx. #{number_to_human_size(aggregate)})#{dry_run_mode_suffix}", :green, true)
      end
    end

    option :start_after
    option :prefix
    option :fix_permissions, type: :boolean, default: false
    option :dry_run, type: :boolean, default: false
    desc 'remove-orphans', 'Scan storage and check for files that do not belong to existing media attachments'
    long_desc <<~LONG_DESC
      Scans file storage for files that do not belong to existing media attachments. Because this operation
      requires iterating over every single file individually, it will be slow.

      Please mind that some storage providers charge for the necessary API requests to list objects.
    LONG_DESC
    def remove_orphans
      progress        = create_progress_bar(nil)
      reclaimed_bytes = 0
      removed         = 0
      prefix          = options[:prefix]

      case Paperclip::Attachment.default_options[:storage]
      when :s3
        paperclip_instance = MediaAttachment.new.file
        s3_interface       = paperclip_instance.s3_interface
        s3_permissions     = Paperclip::Attachment.default_options[:s3_permissions]
        bucket             = s3_interface.bucket(Paperclip::Attachment.default_options[:s3_credentials][:bucket])
        last_key           = options[:start_after]

        loop do
          objects = begin
            bucket.objects(start_after: last_key, prefix: prefix).limit(1000).map { |x| x }
          rescue => e
            progress.log(pastel.red("Error fetching list of files: #{e}"))
            progress.log("If you want to continue from this point, add --start-after=#{last_key} to your command") if last_key
            break
          end

          break if objects.empty?

          last_key   = objects.last.key
          record_map = preload_records_from_mixed_objects(objects)

          objects.each do |object|
            object.acl.put(acl: s3_permissions) if options[:fix_permissions] && !dry_run?

            path_segments = object.key.split('/')
            path_segments.delete('cache')

            unless VALID_PATH_SEGMENTS_SIZE.include?(path_segments.size)
              progress.log(pastel.yellow("Unrecognized file found: #{object.key}"))
              next
            end

            model_name      = path_segments.first.classify
            attachment_name = path_segments[1].singularize
            record_id       = path_segments[2...-2].join.to_i
            file_name       = path_segments.last
            record          = record_map.dig(model_name, record_id)
            attachment      = record&.public_send(attachment_name)

            progress.increment

            next unless attachment.blank? || !attachment.variant?(file_name)

            begin
              object.delete unless dry_run?

              reclaimed_bytes += object.size
              removed += 1

              progress.log("Found and removed orphan: #{object.key}")
            rescue => e
              progress.log(pastel.red("Error processing #{object.key}: #{e}"))
            end
          end
        end
      when :fog
        fail_with_message 'The fog storage driver is not supported for this operation at this time'
      when :azure
        fail_with_message 'The azure storage driver is not supported for this operation at this time'
      when :filesystem
        require 'find'

        root_path = Rails.configuration.x.file_storage_root_path.gsub(':rails_root', Rails.root.to_s)

        Find.find(File.join(*[root_path, prefix].compact)) do |path|
          next if File.directory?(path)

          key = path.gsub("#{root_path}#{File::SEPARATOR}", '')

          path_segments = key.split(File::SEPARATOR)
          path_segments.delete('cache')

          unless VALID_PATH_SEGMENTS_SIZE.include?(path_segments.size)
            progress.log(pastel.yellow("Unrecognized file found: #{key}"))
            next
          end

          model_name      = path_segments.first.classify
          record_id       = path_segments[2...-2].join.to_i
          attachment_name = path_segments[1].singularize
          file_name       = path_segments.last

          next unless PRELOAD_MODEL_WHITELIST.include?(model_name)

          record     = model_name.constantize.find_by(id: record_id)
          attachment = record&.public_send(attachment_name)

          progress.increment

          next unless attachment.blank? || !attachment.variant?(file_name)

          begin
            size = File.size(path)

            unless dry_run?
              File.delete(path)
              begin
                FileUtils.rmdir(File.dirname(path), parents: true)
              rescue Errno::ENOTEMPTY
                # OK
              end
            end

            reclaimed_bytes += size
            removed += 1

            progress.log("Found and removed orphan: #{key}")
          rescue => e
            progress.log(pastel.red("Error processing #{key}: #{e}"))
          end
        end
      end

      progress.total = progress.progress
      progress.finish

      say("Removed #{removed} orphans (approx. #{number_to_human_size(reclaimed_bytes)})#{dry_run_mode_suffix}", :green, true)
    end

    option :account, type: :string
    option :domain, type: :string
    option :status, type: :numeric
    option :days, type: :numeric
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

      Use the --days option to limit attachments created within days.

      By default, attachments that are believed to be already downloaded will
      not be re-downloaded. To force re-download of every URL, use --force.
    DESC
    def refresh
      if options[:status]
        scope = MediaAttachment.where(status_id: options[:status])
      elsif options[:account]
        username, domain = options[:account].split('@')
        account = Account.find_remote(username, domain)

        fail_with_message 'No such account' if account.nil?

        scope = MediaAttachment.where(account_id: account.id)
      elsif options[:domain]
        scope = MediaAttachment.joins(:account).merge(Account.by_domain_and_subdomains(options[:domain]))
      elsif options[:days].present?
        scope = MediaAttachment.remote
      else
        fail_with_message 'Specify the source of media attachments'
      end

      scope = scope.where('media_attachments.id > ?', Mastodon::Snowflake.id_at(options[:days].days.ago, with_random: false)) if options[:days].present?

      processed, aggregate = parallelize_with_progress(scope) do |media_attachment|
        next if media_attachment.remote_url.blank? || (!options[:force] && media_attachment.file_file_name.present?)
        next if DomainBlock.reject_media?(media_attachment.account.domain)

        unless dry_run?
          media_attachment.reset_file!
          media_attachment.reset_thumbnail!
          media_attachment.save
        end

        media_attachment.file_file_size + (media_attachment.thumbnail_file_size || 0)
      end

      say("Downloaded #{processed} media attachments (approx. #{number_to_human_size(aggregate)})#{dry_run_mode_suffix}", :green, true)
    end

    desc 'usage', 'Calculate disk space consumed by Mastodon'
    def usage
      say("Attachments:\t#{number_to_human_size(media_attachment_storage_size)} (#{number_to_human_size(local_media_attachment_storage_size)} local)")
      say("Custom emoji:\t#{number_to_human_size(CustomEmoji.sum(:image_file_size))} (#{number_to_human_size(CustomEmoji.local.sum(:image_file_size))} local)")
      say("Preview cards:\t#{number_to_human_size(PreviewCard.sum(:image_file_size))}")
      say("Avatars:\t#{number_to_human_size(Account.sum(:avatar_file_size))} (#{number_to_human_size(Account.local.sum(:avatar_file_size))} local)")
      say("Headers:\t#{number_to_human_size(Account.sum(:header_file_size))} (#{number_to_human_size(Account.local.sum(:header_file_size))} local)")
      say("Backups:\t#{number_to_human_size(Backup.sum(:dump_file_size))}")
      say("Imports:\t#{number_to_human_size(Import.sum(:data_file_size))}")
      say("Settings:\t#{number_to_human_size(SiteUpload.sum(:file_file_size))}")
    end

    desc 'lookup URL', 'Lookup where media is displayed by passing a media URL'
    def lookup(url)
      path = Addressable::URI.parse(url).path

      path_segments = path.split('/')[2..]
      path_segments.delete('cache')

      fail_with_message 'Not a media URL' unless VALID_PATH_SEGMENTS_SIZE.include?(path_segments.size)

      model_name = path_segments.first.classify
      record_id  = path_segments[2...-2].join.to_i

      fail_with_message "Cannot find corresponding model: #{model_name}" unless PRELOAD_MODEL_WHITELIST.include?(model_name)

      record = model_name.constantize.find_by(id: record_id)
      record = record.status if record.respond_to?(:status)

      fail_with_message 'Cannot find corresponding record' unless record

      display_url = ActivityPub::TagManager.instance.url_for(record)

      fail_with_message 'No public URL for this type of record' if display_url.blank?

      say(display_url, :blue)
    rescue Addressable::URI::InvalidURIError
      fail_with_message 'Invalid URL'
    end

    private

    def media_attachment_storage_size
      MediaAttachment.sum(file_and_thumbnail_size_sql)
    end

    def local_media_attachment_storage_size
      MediaAttachment.where(account: Account.local).sum(file_and_thumbnail_size_sql)
    end

    def file_and_thumbnail_size_sql
      Arel.sql(
        <<~SQL.squish
          COALESCE(file_file_size, 0) + COALESCE(thumbnail_file_size, 0)
        SQL
      )
    end

    PRELOAD_MODEL_WHITELIST = %w(
      Account
      Backup
      CustomEmoji
      Import
      MediaAttachment
      PreviewCard
      SiteUpload
    ).freeze

    def preload_records_from_mixed_objects(objects)
      preload_map = Hash.new { |hash, key| hash[key] = [] }

      objects.map do |object|
        segments = object.key.split('/')
        segments.delete('cache')

        next unless VALID_PATH_SEGMENTS_SIZE.include?(segments.size)

        model_name = segments.first.classify
        record_id  = segments[2...-2].join.to_i

        next unless PRELOAD_MODEL_WHITELIST.include?(model_name)

        preload_map[model_name] << record_id
      end

      preload_map.each_with_object({}) do |(model_name, record_ids), model_map|
        model_map[model_name] = model_name.constantize.where(id: record_ids).index_by(&:id)
      end
    end
  end
end
