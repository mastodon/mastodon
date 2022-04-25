# frozen_string_literal: true

class DeleteAccountService < BaseService
  include Payloadable

  # Suspend or remove an account and remove as much of its data
  # as possible. If it's a local account and it has not been confirmed
  # or never been approved, then side effects are skipped and both
  # the user and account records are removed fully. Otherwise,
  # it is controlled by options.
  # @param [Account]
  # @param [Hash] options
  # @option [Boolean] :reserve_email Keep user record. Only applicable for local accounts
  # @option [Boolean] :reserve_username Keep account record
  # @option [Boolean] :skip_side_effects Side effects are ActivityPub and streaming API payloads
  # @option [Boolean] :skip_activitypub Skip sending ActivityPub payloads. Implied by :skip_side_effects
  # @option [Time]    :suspended_at Only applicable when :reserve_username is true
  def call(account, **options)
    @account = account
    @options = { reserve_username: true, reserve_email: true }.merge(options)

    if @account.local? && @account.user_unconfirmed_or_pending?
      @options[:reserve_email]     = false
      @options[:reserve_username]  = false
      @options[:skip_side_effects] = true
    end

    @options[:skip_activitypub] = true if @options[:skip_side_effects]

    distribute_activities!
    purge_user!
    purge_profile!
    purge_content!
    fulfill_deletion_request!
  end

  private

  def distribute_activities!
    return if skip_activitypub?

    if @account.local?
      delete_actor!
    elsif @account.activitypub?
      reject_follows!
      undo_follows!
    end
  end

  def reject_follows!
    # When deleting a remote account, the account obviously doesn't
    # actually become deleted on its origin server, i.e. unlike a
    # locally deleted account it continues to have access to its home
    # feed and other content. To prevent it from being able to continue
    # to access toots it would receive because it follows local accounts,
    # we have to force it to unfollow them.

    ActivityPub::DeliveryWorker.push_bulk(Follow.where(account: @account)) do |follow|
      [Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer)), follow.target_account_id, @account.inbox_url]
    end
  end

  def undo_follows!
    # When deleting a remote account, the account obviously doesn't
    # actually become deleted on its origin server, but following relationships
    # are severed on our end. Therefore, make the remote server aware that the
    # follow relationships are severed to avoid confusion and potential issues
    # if the remote account gets un-suspended.

    ActivityPub::DeliveryWorker.push_bulk(Follow.where(target_account: @account)) do |follow|
      [Oj.dump(serialize_payload(follow, ActivityPub::UndoFollowSerializer)), follow.account_id, @account.inbox_url]
    end
  end

  def purge_user!
    return if !@account.local? || @account.user.nil?

    if keep_user_record?
      @account.user.disable!
      @account.user.invites.where(uses: 0).destroy_all
    else
      @account.user.destroy
    end
  end

  def purge_content!
    AccountPurgeWorker.perform_async(@account.id, { 'reserve_username' => @options[:reserve_username], 'skip_side_effects' => @options[:skip_side_effects] })
  end

  def purge_profile!
    # If the account is going to be destroyed
    # there is no point wasting time updating
    # its values first

    return unless keep_account_record?

    @account.silenced_at         = nil
    @account.suspended_at        = @options[:suspended_at] || Time.now.utc
    @account.suspension_origin   = :local
    @account.locked              = false
    @account.memorial            = false
    @account.discoverable        = false
    @account.trendable           = false
    @account.display_name        = ''
    @account.note                = ''
    @account.fields              = []
    @account.statuses_count      = 0
    @account.followers_count     = 0
    @account.following_count     = 0
    @account.moved_to_account    = nil
    @account.reviewed_at         = nil
    @account.requested_review_at = nil
    @account.also_known_as       = []
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end

  def fulfill_deletion_request!
    @account.deletion_request&.destroy
  end

  def delete_actor!
    ActivityPub::DeliveryWorker.push_bulk(delivery_inboxes) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(low_priority_delivery_inboxes) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end
  end

  def delete_actor_json
    @delete_actor_json ||= Oj.dump(serialize_payload(@account, ActivityPub::DeleteActorSerializer, signer: @account, always_sign: true))
  end

  def delivery_inboxes
    @delivery_inboxes ||= @account.followers.inboxes + Relay.enabled.pluck(:inbox_url)
  end

  def low_priority_delivery_inboxes
    Account.inboxes - delivery_inboxes
  end

  def keep_user_record?
    @options[:reserve_email]
  end

  def keep_account_record?
    @options[:reserve_username]
  end

  def skip_side_effects?
    @options[:skip_side_effects]
  end

  def skip_activitypub?
    @options[:skip_activitypub]
  end
end
