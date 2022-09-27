# frozen_string_literal: true

class RevokeMembershipService < BaseService
  include Payloadable

  def call(membership)
    return unless membership.group.local?

    # TODO: logging

    send_reject!(membership) unless membership.account.local?
    distribute_remove_to_remote_members!(membership)

    membership.destroy
  end

  private

  def send_reject!(request)
    json = Oj.dump(serialize_payload(request, ActivityPub::RejectJoinSerializer))
    ActivityPub::GroupDeliveryWorker.perform_async(json, request.group.id, request.account.inbox_url)
  end

  def distribute_remove_to_remote_members!(membership)
    json = Oj.dump(serialize_payload(membership.account, ActivityPub::RemoveSerializer, target: ActivityPub::TagManager.instance.members_uri_for(membership.group), actor: ActivityPub::TagManager.instance.uri_for(membership.group)))
    ActivityPub::GroupRawDistributionWorker.perform_async(json, membership.group.id, [membership.account.inbox_url])
  end
end
