# frozen_string_literal: true

class SuspendAccountService < BaseService
  def call(account, **options)
    @account = account
    @options = options

    purge_user!
    purge_profile!
    purge_content!
    unsubscribe_push_subscribers!
  end

  private

  def purge_user!
    if @options[:remove_user]
      @account.user&.destroy
    else
      @account.user&.disable!
    end
  end

  def purge_content!
    ActivityPub::RawDistributionWorker.perform_async(delete_actor_json, @account.id) if @account.local?

    @account.statuses.reorder(nil).find_in_batches do |statuses|
      BatchedRemoveStatusService.new.call(statuses)
    end

    [
      @account.media_attachments,
      @account.stream_entries,
      @account.notifications,
      @account.favourites,
      @account.active_relationships,
      @account.passive_relationships,
    ].each do |association|
      destroy_all(association)
    end
  end

  def purge_profile!
    @account.suspended      = true
    @account.display_name   = ''
    @account.note           = ''
    @account.statuses_count = 0
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end

  def unsubscribe_push_subscribers!
    destroy_all(@account.subscriptions)
  end

  def destroy_all(association)
    association.in_batches.destroy_all
  end

  def delete_actor_json
    payload = ActiveModelSerializers::SerializableResource.new(
      @account,
      serializer: ActivityPub::DeleteActorSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(@account))
  end
end
