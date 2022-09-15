# frozen_string_literal: true

class SuspendGroupService < BaseService
  include Payloadable

  def call(group)
    @group = group

    suspend!
    distribute_update_actor!

    # TODO: what do we do if we want to immediately stop receiving content from a remote group?
  end

  private

  def suspend!
    @group.suspend! unless @group.suspended?
  end

  def distribute_update_actor!
    return unless @group.local?

    # TODO
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(serialize_payload(@group, ActivityPub::UpdateSerializer, signer: @group))
  end
end
