# frozen_string_literal: true

class UnsuspendAccountService < BaseService
  def call(account)
    @account = account

    unsuspend!
    refresh_remote_account!

    return if @account.nil?

    merge_into_home_timelines!
    merge_into_list_timelines!
    publish_media_attachments!
  end

  private

  def unsuspend!
    @account.unsuspend! if @account.suspended?
  end

  def refresh_remote_account!
    return if @account.local?

    # While we had the remote account suspended, it could be that
    # it got suspended on its origin, too. So, we need to refresh
    # it straight away so it gets marked as remotely suspended in
    # that case.

    @account.update!(last_webfingered_at: nil)
    @account = ResolveAccountService.new.call(@account)

    # Worth noting that it is possible that the remote has not only
    # been suspended, but deleted permanently, in which case
    # @account would now be nil.
  end

  def merge_into_home_timelines!
    @account.followers_for_local_distribution.find_each do |follower|
      FeedManager.instance.merge_into_home(@account, follower)
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

        next if attachment.blank?

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            begin
              attachment.s3_object(style).acl.put(acl: Paperclip::Attachment.default_options[:s3_permissions])
            rescue Aws::S3::Errors::NoSuchKey
              Rails.logger.warn "Tried to change acl on non-existent key #{attachment.s3_object(style).key}"
            end
          when :fog
            # Not supported
          when :filesystem
            begin
              FileUtils.chmod(0o666 & ~File.umask, attachment.path(style)) unless attachment.path(style).nil?
            rescue Errno::ENOENT
              Rails.logger.warn "Tried to change permission on non-existent file #{attachment.path(style)}"
            end
          end

          CacheBusterWorker.perform_async(attachment.path(style)) if Rails.configuration.x.cache_buster_enabled
        end
      end
    end
  end
end
