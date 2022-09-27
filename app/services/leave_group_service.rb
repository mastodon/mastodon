# frozen_string_literal: true

class LeaveGroupService < BaseService
  include Payloadable
  include Redisable
  include Lockable

  # @param [Account] account Where to leave from
  # @param [Group] group Which group to unfollow
  def call(account, group)
    @account = account
    @group   = group

    leave! || undo_join_request!
  end

  private

  def leave!
    membership = GroupMembership.find_by(account: @account, group: @group)

    return unless membership

    membership.destroy!

    send_leave!(membership) if @account.local? && !@group.local?
    send_reject!(membership) if @group.local? && !@account.local?

    membership
  end

  def undo_join_request!
    membership_request = GroupMembershipRequest.find_by(account: @account, group: @group)

    return unless membership_request

    membership_request.destroy!

    send_undo!(membership_request) if @account.local? && !@group.local?

    membership_request
  end

  def send_leave!(membership)
    # TODO
  end

  def send_reject!(membership)
    # TODO
  end

  def send_undo!(membership_request)
    # TODO
  end
end
