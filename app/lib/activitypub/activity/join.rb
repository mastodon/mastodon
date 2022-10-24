# frozen_string_literal: true

class ActivityPub::Activity::Join < ActivityPub::Activity
  include Payloadable

  def perform
    return if @json['id'].present? && invalid_origin?(@json['id'])

    return if @options[:delivered_to_group_id].blank?
    group = Group.find(@options[:delivered_to_group_id])
    return if object_uri != ActivityPub::TagManager.instance.uri_for(group)

    return if !group.local? || delete_arrived_first?(@json['id'])

    # Update id of already-existing membership requests
    existing_request = GroupMembershipRequest.find_by(account: @account, group: group)
    if existing_request.present?
      existing_request.update!(uri: @json['id'])
      return
    end

    return reject_join_request!(group) if group.suspended? || group.blocking?(@account)

    # Fast-forward repeat follow requests
    existing_membership = GroupMembership.find_by(account: @account, group: group)
    if existing_membership.present?
      existing_membership.update!(uri: @json['id'])
      accept_join_request!(existing_membership)
      return
    end

    membership_request = GroupMembershipRequest.create!(account: @account, group: group, uri: @json['id'])

    if group.locked? || @account.silenced?
      # TODO: LocalNotificationWorker.perform_async(target_account.id, follow_request.id, 'FollowRequest', 'follow_request')
    else
      AuthorizeMembershipService.new.call(membership_request)
      # TODO: LocalNotificationWorker.perform_async(target_account.id, ::Follow.find_by(account: @account, target_account: target_account).id, 'Follow', 'follow')
    end
  end

  def reject_join_request!(group)
    json = Oj.dump(serialize_payload(GroupMembershipRequest.new(account: @account, group: group, uri: @json['id']), ActivityPub::RejectJoinSerializer))
    ActivityPub::GroupDeliveryWorker.perform_async(json, group.id, @account.inbox_url)
  end

  def accept_join_request!(request)
    json = Oj.dump(serialize_payload(request, ActivityPub::AcceptJoinSerializer))
    ActivityPub::GroupDeliveryWorker.perform_async(json, request.group.id, @account.inbox_url)
  end
end
