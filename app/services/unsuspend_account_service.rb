# frozen_string_literal: true

class UnsuspendAccountService < BaseService
  def call(account)
    @account = account

    unsuspend!
    merge_into_home_timelines!
    merge_into_list_timelines!
    publish_media_attachments!
  end

  private

  def unsuspend!
    @account.unsuspend! if @account.suspended?
  end

  def merge_into_home_timelines!
    @account.followers_for_local_distribution.find_each do |follower|
      FeedManager.instance.merge_into_timeline(@account, follower)
    end
  end

  def merge_into_list_timelines!
    @account.lists_for_local_distribution.find_each do |list|
      FeedManager.instance.merge_into_list(@account, list)
    end
  end

  def publish_media_attachments!
    attachment_names = MediaAttachment.attachment_definitions.keys

    @account.media_attachments.find_each do |media_attachment|
      attachment_names.each do |attachment_name|
        attachment = media_attachment.public_send(attachment_name)
        styles     = [:original] | attachment.styles.keys

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            attachment.s3_object(style).acl.put(Paperclip::Attachment.default_options[:s3_permissions])
          when :fog
            # Not supported
          when :filesystem
            FileUtils.chmod(0o666 & ~File.umask, attachment.path(style))
          end
        end
      end
    end
  end
end
