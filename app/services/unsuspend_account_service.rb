# frozen_string_literal: true

class UnsuspendAccountService < BaseService
  include Payloadable

  # Restores a recently-unsuspended account
  # @param [Account] account Account to restore
  def call(account)
    @account = account

    refresh_remote_account!

    return if @account.nil? || @account.suspended?

    merge_into_home_timelines!
    merge_into_list_timelines!
    publish_media_attachments!
    distribute_update_actor!
  end

  private

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

  def distribute_update_actor!
    return unless @account.local?

    account_reach_finder = AccountReachFinder.new(@account)

    ActivityPub::DeliveryWorker.push_bulk(account_reach_finder.inboxes, limit: 1_000) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end
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
        styles     = MediaAttachment::DEFAULT_STYLES | attachment.styles.keys

        next if attachment.blank?

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            # Prevent useless S3 calls if ACLs are disabled
            next if ENV['S3_PERMISSION'] == ''

            begin
              attachment.s3_object(style).acl.put(acl: Paperclip::Attachment.default_options[:s3_permissions])
            rescue Aws::S3::Errors::NoSuchKey
              Rails.logger.warn "Tried to change acl on non-existent key #{attachment.s3_object(style).key}"
            rescue Aws::S3::Errors::NotImplemented => e
              Rails.logger.error "Error trying to change ACL on #{attachment.s3_object(style).key}: #{e.message}"
            end
          when :fog, :azure
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

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@account, ActivityPub::UpdateSerializer, signer: @account))
  end
end
