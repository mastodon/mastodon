# frozen_string_literal: true

class ActivityPub::Activity::Leave < ActivityPub::Activity
  include Payloadable

  def perform
    return if @options[:delivered_to_group_id].blank?
    group = Group.find(@options[:delivered_to_group_id])
    return if object_uri != ActivityPub::TagManager.instance.uri_for(group)

    membership = group.memberships.find_by(account: @account)
    return if membership.blank?

    membership.destroy!

    distribute_remove_to_remote_members!(membership)
  end

  def distribute_remove_to_remote_members!(membership)
    json = Oj.dump(serialize_payload(membership.account, ActivityPub::RemoveSerializer, target: ActivityPub::TagManager.instance.members_uri_for(membership.group), actor: ActivityPub::TagManager.instance.uri_for(membership.group)))
    ActivityPub::GroupRawDistributionWorker.perform_async(json, membership.group.id, [membership.account.inbox_url])
  end
end
