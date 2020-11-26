# frozen_string_literal: true

class SuspendAccountService < BaseService
  include Payloadable

  def call(account)
    @account = account

    suspend!
    reject_remote_follows!
    distribute_update_actor!
    unmerge_from_home_timelines!
    unmerge_from_list_timelines!
    privatize_media_attachments!
  end

  private

  def suspend!
    @account.suspend! unless @account.suspended?
  end

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

    follows = Follow.where(account: @account).to_a

    ActivityPub::DeliveryWorker.push_bulk(follows) do |follow|
      [Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer)), follow.target_account_id, @account.inbox_url]
    end

    follows.each(&:destroy)
  end

  def distribute_update_actor!
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id) if @account.local?
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
        styles     = [:original] | attachment.styles.keys

        styles.each do |style|
          case Paperclip::Attachment.default_options[:storage]
          when :s3
            attachment.s3_object(style).acl.put(acl: 'private')
          when :fog
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
end
