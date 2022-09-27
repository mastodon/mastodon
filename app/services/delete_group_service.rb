# frozen_string_literal: true

class DeleteGroupService < BaseService
  include Payloadable

  ASSOCIATIONS_ON_SUSPEND = %w(
    memberships
    membership_requests
    account_blocks
  ).freeze

  # The following associations have no important side-effects
  # in callbacks and all of their own associations are secured
  # by foreign keys, making them safe to delete without loading
  # into memory
  ASSOCIATIONS_WITHOUT_SIDE_EFFECTS = %w(
    memberships
    membership_requests
    account_blocks
  )

  ASSOCIATIONS_ON_DESTROY = %w(
  ).freeze

  # Suspend or remove a group and remove as much of its data
  # as possible.
  # @param [Group]
  # @param [Hash] options
  # @option [Boolean] :keep_record Keep group record
  # @option [Boolean] :skip_side_effects Side effects are ActivityPub and streaming API payloads
  # @option [Boolean] :skip_activitypub Skip sending ActivityPub payloads. Implied by :skip_side_effects
  # @option [Time]    :suspended_at Only applicable when :keep_record is true
  def call(group, **options)
    @group = group
    @options = options

    @options[:skip_activitypub] = true if @options[:skip_side_effects]

    distribute_activities!
    purge_content!
    fulfill_deletion_request!
  end

  private

  def distribute_activities!
    return if skip_activitypub?

    if @group.local?
      delete_actor!
    else
      delete_posts!
      leave_group!
    end
  end

  def delete_posts!
    # TODO: send a deletion notice for any local group post
  end

  def leave_group!
    # TODO: send a Leave activity for any local group member
  end

  def purge_content!
    purge_profile!
    purge_statuses!
    purge_other_associations!

    @group.destroy unless keep_group_record?
  end

  def purge_statuses!
    @group.statuses.reorder(nil).find_each do |status|
      status.destroy! unless status.reported? # TODO: do something more efficient, but BatchedRemoveStatusService is not safe in our case
    end
  end

  def purge_other_associations!
    associations_for_destruction.each do |association_name|
      purge_association(association_name)
    end
  end

  def purge_profile!
    # If the account is going to be destroyed
    # there is no point wasting time updating
    # its values first

    return unless keep_group_record?

    @group.suspended_at        = @options[:suspended_at] || Time.now.utc
    @group.suspension_origin   = :local
    @group.locked              = false
    @group.display_name        = ''
    @group.statuses_count      = 0
    @group.members_count       = 0
    @group.avatar.destroy
    @group.header.destroy
    @group.save!
  end

  def fulfill_deletion_request!
    @group.deletion_request&.destroy
  end

  def purge_association(association_name)
    association = @group.public_send(association_name)

    if ASSOCIATIONS_WITHOUT_SIDE_EFFECTS.include?(association_name)
      association.in_batches.delete_all
    else
      association.in_batches.destroy_all
    end
  end

  def delete_actor!
    ActivityPub::GroupDeliveryWorker.push_bulk(delivery_inboxes) do |inbox_url|
      [delete_actor_json, @group.id, inbox_url]
    end

    # TODO:
    #ActivityPub::LowPriorityDeliveryWorker.push_bulk(low_priority_delivery_inboxes) do |inbox_url|
    #  [delete_actor_json, @account.id, inbox_url]
    #end
  end

  def delete_actor_json
    @delete_actor_json ||= Oj.dump(serialize_payload(@group, ActivityPub::DeleteActorSerializer, signer: @group, always_sign: true))
  end

  def delivery_inboxes
    @delivery_inboxes ||= @group.members.inboxes
  end

  def associations_for_destruction
    if keep_group_record?
      ASSOCIATIONS_ON_SUSPEND
    else
      ASSOCIATIONS_ON_SUSPEND + ASSOCIATIONS_ON_DESTROY
    end
  end

  def keep_group_record?
    @options[:keep_record]
  end

  def skip_side_effects?
    @options[:skip_side_effects]
  end

  def skip_activitypub?
    @options[:skip_activitypub]
  end
end
