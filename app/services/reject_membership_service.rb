# frozen_string_literal: true

class RejectMembershipService < BaseService
  include Payloadable

  def call(membership_request)
    membership_request.reject!

    # TODO: logging

    send_reject!(membership_request) if membership_request.group.local? && !membership_request.account.local?
    membership_request
  end

  private

  def send_reject!(request)
    json = Oj.dump(serialize_payload(request, ActivityPub::RejectJoinSerializer))
    ActivityPub::GroupDeliveryWorker.perform_async(json, request.group.id, request.account.inbox_url)
  end
end
