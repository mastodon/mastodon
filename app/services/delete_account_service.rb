# frozen_string_literal: true

class DeleteAccountService < BaseService
  include Payloadable

  ASSOCIATIONS_ON_SUSPEND = %w(
    account_pins
    active_relationships
    block_relationships
    blocked_by_relationships
    conversation_mutes
    conversations
    custom_filters
    domain_blocks
    favourites
    follow_requests
    list_accounts
    mute_relationships
    muted_by_relationships
    notifications
    owned_lists
    passive_relationships
    report_notes
    scheduled_statuses
    status_pins
  ).freeze

  ASSOCIATIONS_ON_DESTROY = %w(
    reports
    targeted_moderation_notes
    targeted_reports
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
  # @option [Time]    :suspended_at Only applicable when :reserve_username is true
  def call(account, **options)
    @account = account
    @options = { reserve_username: true, reserve_email: true }.merge(options)

    if @account.local? && @account.user_unconfirmed_or_pending?
      @options[:reserve_email]     = false
      @options[:reserve_username]  = false
      @options[:skip_side_effects] = true
    end

    reject_follows!
    purge_user!
    purge_profile!
    purge_content!
    fulfill_deletion_request!
  end

  private

  def reject_follows!
    return if @account.local? || !@account.activitypub?

    ActivityPub::DeliveryWorker.push_bulk(Follow.where(account: @account)) do |follow|
      [build_reject_json(follow), follow.target_account_id, follow.account.inbox_url]
    end
  end

  def purge_user!
    return if !@account.local? || @account.user.nil?

    if @options[:reserve_email]
      @account.user.disable!
      @account.user.invites.where(uses: 0).destroy_all
    else
      @account.user.destroy
    end
  end

  def purge_content!
    distribute_delete_actor! if @account.local? && !@options[:skip_side_effects]

    @account.statuses.reorder(nil).find_in_batches do |statuses|
      statuses.reject! { |status| reported_status_ids.include?(status.id) } if @options[:reserve_username]
      BatchedRemoveStatusService.new.call(statuses, skip_side_effects: @options[:skip_side_effects])
    end

    @account.media_attachments.reorder(nil).find_each do |media_attachment|
      next if @options[:reserve_username] && reported_status_ids.include?(media_attachment.status_id)

      media_attachment.destroy
    end

    @account.polls.reorder(nil).find_each do |poll|
      next if @options[:reserve_username] && reported_status_ids.include?(poll.status_id)

      poll.destroy
    end

    associations_for_destruction.each do |association_name|
      destroy_all(@account.public_send(association_name))
    end

    @account.destroy unless @options[:reserve_username]
  end

  def purge_profile!
    # If the account is going to be destroyed
    # there is no point wasting time updating
    # its values first

    return unless @options[:reserve_username]

    @account.silenced_at      = nil
    @account.suspended_at     = @options[:suspended_at] || Time.now.utc
    @account.locked           = false
    @account.memorial         = false
    @account.discoverable     = false
    @account.display_name     = ''
    @account.note             = ''
    @account.fields           = []
    @account.statuses_count   = 0
    @account.followers_count  = 0
    @account.following_count  = 0
    @account.moved_to_account = nil
    @account.trust_level      = :untrusted
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end

  def fulfill_deletion_request!
    @account.deletion_request&.destroy
  end

  def destroy_all(association)
    association.in_batches.destroy_all
  end

  def distribute_delete_actor!
    ActivityPub::DeliveryWorker.push_bulk(delivery_inboxes) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(low_priority_delivery_inboxes) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end
  end

  def delete_actor_json
    @delete_actor_json ||= Oj.dump(serialize_payload(@account, ActivityPub::DeleteActorSerializer, signer: @account))
  end

  def build_reject_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer))
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
    if @options[:reserve_username]
      ASSOCIATIONS_ON_SUSPEND
    else
      ASSOCIATIONS_ON_SUSPEND + ASSOCIATIONS_ON_DESTROY
    end
  end
end
