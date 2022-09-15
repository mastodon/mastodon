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

    # TODO: look at how UnsuspendAccountService does it, but we need the split-class federation code
  end

  def distribute_update_actor!
    return unless @group.local?

    # TODO: look at how UnsuspendAccountService does it, but we need the split-class federation code
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@group, ActivityPub::UpdateSerializer, signer: @group))
  end
end
