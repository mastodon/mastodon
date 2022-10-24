# frozen_string_literal: true

class AuthorizeMembershipService < BaseService
  include Payloadable

  def call(membership_request)
    membership_request.authorize!

    # TODO: logging

    if membership_request.group.local?
      send_accept_join!(membership_request) unless membership_request.account.local?
      distribute_add_to_remote_members!(membership_request)
    end

    membership_request
  end

  private

  def send_accept_join!(request)
    json = Oj.dump(serialize_payload(request, ActivityPub::AcceptJoinSerializer))
    ActivityPub::GroupDeliveryWorker.perform_async(json, request.group.id, request.account.inbox_url)
  end

  def distribute_add_to_remote_members!(request)
    json = Oj.dump(serialize_payload(request.account, ActivityPub::AddSerializer, target: ActivityPub::TagManager.instance.members_uri_for(request.group), actor: ActivityPub::TagManager.instance.uri_for(request.group)))
    ActivityPub::GroupRawDistributionWorker.perform_async(json, request.group.id, [request.account.inbox_url])
  end
end
