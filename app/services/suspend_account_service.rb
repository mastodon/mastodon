# frozen_string_literal: true

class SuspendAccountService < BaseService
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
    media_attachments
    mute_relationships
    muted_by_relationships
    notifications
    owned_lists
    passive_relationships
    report_notes
    scheduled_statuses
    status_pins
    stream_entries
    subscriptions
  ).freeze

  ASSOCIATIONS_ON_DESTROY = %w(
    reports
    targeted_moderation_notes
    targeted_reports
  ).freeze

  # Suspend an account and remove as much of its data as possible
  # @param [Account]
  # @param [Hash] options
  # @option [Boolean] :including_user Remove the user record as well
  # @option [Boolean] :destroy Remove the account record instead of suspending
  def call(account, **options)
    @account = account
    @options = options

    purge_user!
    purge_profile!
    purge_content!
  end

  private

  def purge_user!
    return if !@account.local? || @account.user.nil?

    if @options[:including_user]
      @account.user.destroy
    else
      @account.user.disable!
    end
  end

  def purge_content!
    distribute_delete_actor! if @account.local?

    @account.statuses.reorder(nil).find_in_batches do |statuses|
      BatchedRemoveStatusService.new.call(statuses, skip_side_effects: @options[:destroy])
    end

    associations_for_destruction.each do |association_name|
      destroy_all(@account.public_send(association_name))
    end

    @account.destroy if @options[:destroy]
  end

  def purge_profile!
    # If the account is going to be destroyed
    # there is no point wasting time updating
    # its values first

    return if @options[:destroy]

    @account.silenced         = false
    @account.suspended        = true
    @account.locked           = false
    @account.display_name     = ''
    @account.note             = ''
    @account.fields           = {}
    @account.statuses_count   = 0
    @account.followers_count  = 0
    @account.following_count  = 0
    @account.moved_to_account = nil
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end

  def destroy_all(association)
    association.in_batches.destroy_all
  end

  def distribute_delete_actor!
    ActivityPub::DeliveryWorker.push_bulk(delivery_inboxes) do |inbox_url|
      [delete_actor_json, @account.id, inbox_url]
    end
  end

  def delete_actor_json
    return @delete_actor_json if defined?(@delete_actor_json)

    payload = ActiveModelSerializers::SerializableResource.new(
      @account,
      serializer: ActivityPub::DeleteActorSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    @delete_actor_json = Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(@account))
  end

  def delivery_inboxes
    Account.inboxes + Relay.enabled.pluck(:inbox_url)
  end

  def associations_for_destruction
    if @options[:destroy]
      ASSOCIATIONS_ON_SUSPEND + ASSOCIATIONS_ON_DESTROY
    else
      ASSOCIATIONS_ON_SUSPEND
    end
  end
end
