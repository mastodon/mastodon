# frozen_string_literal: true

class SuspendAccountService < BaseService
  include Payloadable

  # Carry out the suspension of a recently-suspended account
  # @param [Account] account Account to suspend
  def call(account)
    return unless account.suspended?

    @account = account

    reject_remote_follows!
    distribute_update_actor!
    unmerge_from_home_timelines!
    unmerge_from_list_timelines!
    privatize_media_attachments!
  end

  private

  def reject_remote_follows!
    return if @account.local? || !@account.activitypub?

    # When suspending a remote account, the account obviously doesn't
    # actually become suspended on its origin server, i.e. unlike a
    # locally suspended account it continues to have access to its home
    # feed and other content. To prevent it from being able to continue
    # to access toots it would receive because it follows local accounts,
    # we have to force it to unfollow them. Unfortunately, there is no
    # counterpart to this operation, i.e. you can't then force a remote
    # account to re-follow you, so this part is not reversible.

    Follow.where(account: @account).find_in_batches do |follows|
      ActivityPub::DeliveryWorker.push_bulk(follows) do |follow|
        [Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer)), follow.target_account_id, @account.inbox_url]
      end

      follows.each(&:destroy)
    end
  end

  def distribute_update_actor!
    return unless @account.local?

    account_reach_finder = AccountReachFinder.new(@account)

    ActivityPub::DeliveryWorker.push_bulk(account_reach_finder.inboxes, limit: 1_000) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end
  end

  def unmerge_from_home_timelines!
    @account.followers_for_local_distribution.find_each do |follower|
      FeedManager.instance.unmerge_from_home(@account, follower)
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
        styles     = MediaAttachment::DEFAULT_STYLES | attachment.styles.keys

        next if attachment.blank?

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            # Prevent useless S3 calls if ACLs are disabled
            next if ENV['S3_PERMISSION'] == ''

            begin
              attachment.s3_object(style).acl.put(acl: 'private')
            rescue Aws::S3::Errors::NoSuchKey
              Rails.logger.warn "Tried to change acl on non-existent key #{attachment.s3_object(style).key}"
            rescue Aws::S3::Errors::NotImplemented => e
              Rails.logger.error "Error trying to change ACL on #{attachment.s3_object(style).key}: #{e.message}"
            end
          when :fog, :azure
            # Not supported
          when :filesystem
            begin
              FileUtils.chmod(0o600 & ~File.umask, attachment.path(style)) unless attachment.path(style).nil?
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
