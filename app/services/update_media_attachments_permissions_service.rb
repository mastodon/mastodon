# frozen_string_literal: true

class UpdateMediaAttachmentsPermissionsService < BaseService
  def call(media_attachments_scope, direction)
    # Only s3 and filesystem storage systems support modifying permissions
    return unless %i(s3 filesystem).include?(Paperclip::Attachment.default_options[:storage])

    # Prevent useless S3 calls if ACLs are disabled
    return if Paperclip::Attachment.default_options[:storage] == :s3 && ENV['S3_PERMISSION'] == ''

    attachment_names = MediaAttachment.attachment_definitions.keys

    media_attachments_scope.find_each do |media_attachment|
      attachment_names.each do |attachment_name|
        attachment = media_attachment.public_send(attachment_name)
        styles     = MediaAttachment::DEFAULT_STYLES | attachment.styles.keys

        next if attachment.blank?

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            acl = direction == :public ? Paperclip::Attachment.default_options[:s3_permissions] : 'private'

            begin
              attachment.s3_object(style).acl.put(acl: acl)
            rescue Aws::S3::Errors::NoSuchKey
              Rails.logger.warn "Tried to change acl on non-existent key #{attachment.s3_object(style).key}"
            rescue Aws::S3::Errors::NotImplemented => e
              Rails.logger.error "Error trying to change ACL on #{attachment.s3_object(style).key}: #{e.message}"
            end
          when :filesystem
            mask = direction == :public ? 0o666 : 0o600

            begin
              FileUtils.chmod(mask & ~File.umask, attachment.path(style)) unless attachment.path(style).nil?
            rescue Errno::ENOENT
              Rails.logger.warn "Tried to change permission on non-existent file #{attachment.path(style)}"
            end
          end

          CacheBusterWorker.perform_async(attachment.url(style)) if Rails.configuration.x.cache_buster.enabled
        end
      end
    end
  end
end
