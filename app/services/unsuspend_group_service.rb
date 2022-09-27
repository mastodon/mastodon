# frozen_string_literal: true

class UnsuspendGroupService < BaseService
  include Payloadable

  def call(group)
    @group = group

    unsuspend!
    refresh_remote_actor!

    return if @group.nil? || @group.suspended?

    distribute_update_actor!
  end

  private

  def unsuspend!
    @group.unsuspend! if @group.suspended?
  end

  def refresh_remote_actor!
    return if @group.local?

    # While we had the remote group suspended, it could be that
    # it got suspended on its origin, too. So, we need to refresh
    # it straight away so it gets marked as remotely suspended in
    # that case.

    @group = ActivityPub::FetchRemoteActorService.new.call(@group.uri)

    # Worth noting that it is possible that the remote has not only
    # been suspended, but deleted permanently, in which case
    # @group would now be nil.
  end

  def distribute_update_actor!
    return unless @group.local?

    inboxes = @group.members.inboxes # This should be widened when we support reporting groups themselves
    ActivityPub::GroupDeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [signed_activity_json, @group.id, inbox_url]
    end
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@group, ActivityPub::UpdateSerializer, signer: @group))
  end
end
