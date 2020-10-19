# frozen_string_literal: true

class SuspendAccountService < BaseService
  def call(account)
    @account = account

    suspend!
    unmerge_from_home_timelines!
    unmerge_from_list_timelines!
    privatize_media_attachments!
  end

  private

  def suspend!
    @account.suspend! unless @account.suspended?
  end

  def unmerge_from_home_timelines!
    @account.followers_for_local_distribution.find_each do |follower|
      FeedManager.instance.unmerge_from_timeline(@account, follower)
    end
  end

  def unmerge_from_list_timelines!
    @account.lists_for_local_distribution.find_each do |list|
      FeedManager.instance.unmerge_from_list(@account, list)
    end
  end

  def privatize_media_attachments!
    attachment_names = MediaAttachment.attachment_definitions.keys

    @account.media_attachments.find_each do |media_attachment|
      attachment_names.each do |attachment_name|
        attachment = media_attachment.public_send(attachment_name)
        styles     = [:original] | attachment.styles.keys

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            attachment.s3_object(style).acl.put(:private)
          when :fog
            # Not supported
          when :filesystem
            FileUtils.chmod(0o600 & ~File.umask, attachment.path(style))
          end
        end
      end
    end
  end
end
