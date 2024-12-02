# frozen_string_literal: true

class DeleteAccountService < BaseService
  include Payloadable

  ASSOCIATIONS_ON_SUSPEND = %w(
    account_notes
    account_pins
    active_relationships
    aliases
    block_relationships
    blocked_by_relationships
    conversation_mutes
    conversations
    custom_filters
    domain_blocks
    featured_tags
    follow_requests
    list_accounts
    migrations
    mute_relationships
    muted_by_relationships
    notifications
    owned_lists
    passive_relationships
    report_notes
    scheduled_statuses
    status_pins
  ).freeze

  # The following associations have no important side-effects
  # in callbacks and all of their own associations are secured
  # by foreign keys, making them safe to delete without loading
  # into memory
  ASSOCIATIONS_WITHOUT_SIDE_EFFECTS = %w(
    account_notes
    account_pins
    aliases
    conversation_mutes
    conversations
    custom_filters
    domain_blocks
    featured_tags
    follow_requests
    list_accounts
    migrations
    mute_relationships
    muted_by_relationships
    notifications
    owned_lists
    scheduled_statuses
    status_pins
    tag_follows
  )

  ASSOCIATIONS_ON_DESTROY = %w(
    reports
    targeted_moderation_notes
    targeted_reports
    severed_relationships
    remote_severed_relationships
  ).freeze

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
  # @option [RelationshipSeveranceEvent] :relationship_severance_event Event used to record severed relationships not initiated by the user
  def call(account, **options)
    @account = account
    @options = { reserve_username: true, reserve_email: true }.merge(options)

    if @account.local? && @account.user_unconfirmed_or_pending?
      @options[:reserve_email]     = false
      @options[:reserve_username]  = false
      @options[:skip_side_effects] = true
    end

    @options[:skip_activitypub] = true if @options[:skip_side_effects]

    record_severed_relationships!
    distribute_activities!
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
    purge_user!
    purge_profile!
    purge_statuses!
    purge_mentions!
    purge_media_attachments!
    purge_polls!
    purge_generated_notifications!
    purge_favourites!
    purge_bookmarks!
    purge_feeds!
    purge_other_associations!

    @account.destroy unless keep_account_record?
  end

  def purge_statuses!
    @account.statuses.reorder(nil).where.not(id: reported_status_ids).in_batches do |statuses|
      BatchedRemoveStatusService.new.call(statuses, skip_side_effects: skip_side_effects?)
    end
  end

  def purge_mentions!
    @account.mentions.reorder(nil).where.not(status_id: reported_status_ids).in_batches.delete_all
  end

  def purge_media_attachments!
    @account.media_attachments.find_each do |media_attachment|
      next if keep_account_record? && reported_status_ids.include?(media_attachment.status_id)

      media_attachment.destroy
    end
  end

  def purge_polls!
    @account.polls.reorder(nil).where.not(status_id: reported_status_ids).in_batches.delete_all
  end

  def purge_generated_notifications!
    # By deleting polls and statuses without callbacks, we've left behind
    # polymorphically associated notifications generated by this account

    Notification.where(from_account: @account).in_batches.delete_all
    NotificationRequest.where(from_account: @account).in_batches.delete_all
  end

  def purge_favourites!
    @account.favourites.in_batches do |favourites|
      ids = favourites.pluck(:status_id)
      StatusStat.where(status_id: ids).update_all('favourites_count = GREATEST(0, favourites_count - 1)')
      Chewy.strategy.current.update(StatusesIndex, ids) if Chewy.enabled?
      Rails.cache.delete_multi(ids.map { |id| "statuses/#{id}" })
      favourites.delete_all
    end
  end

  def purge_bookmarks!
    @account.bookmarks.in_batches do |bookmarks|
      Chewy.strategy.current.update(StatusesIndex, bookmarks.pluck(:status_id)) if Chewy.enabled?
      bookmarks.delete_all
    end
  end

  def purge_other_associations!
    associations_for_destruction.each do |association_name|
      purge_association(association_name)
    end
  end

  def purge_feeds!
    return unless @account.local?

    FeedManager.instance.clean_feeds!(:home, [@account.id])
    FeedManager.instance.clean_feeds!(:list, @account.owned_lists.pluck(:id))
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

  def purge_association(association_name)
    association = @account.public_send(association_name)

    if ASSOCIATIONS_WITHOUT_SIDE_EFFECTS.include?(association_name)
      association.in_batches.delete_all
    else
      association.in_batches.destroy_all
    end
  end

  def delete_actor!
    ActivityPub::DeliveryWorker.push_bulk(delivery_inboxes, limit: 1_000) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(low_priority_delivery_inboxes, limit: 1_000) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end
  end

  def record_severed_relationships!
    return if relationship_severance_event.nil?

    @account.active_relationships.in_batches do |follows|
      # NOTE: these follows are passive with regards to the local accounts
      relationship_severance_event.import_from_passive_follows!(follows)
    end

    @account.passive_relationships.in_batches do |follows|
      # NOTE: these follows are active with regards to the local accounts
      relationship_severance_event.import_from_active_follows!(follows)
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

  def reported_status_ids
    @reported_status_ids ||= Report.where(target_account: @account).unresolved.pluck(:status_ids).flatten.uniq
  end

  def associations_for_destruction
    if keep_account_record?
      ASSOCIATIONS_ON_SUSPEND
    else
      ASSOCIATIONS_ON_SUSPEND + ASSOCIATIONS_ON_DESTROY
    end
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

  def relationship_severance_event
    @options[:relationship_severance_event]
  end
end
