# frozen_string_literal: true

class RejectMembershipService < BaseService
  include Payloadable

  def call(membership_request)
    membership_request.reject!

    # TODO: logging

    create_notification(membership_request) if !membership_request.account.local? && membership_request.group.local?
    membership_request
  end

  private

  def create_notification(membership_request)
    # TODO: federation
  end
end
