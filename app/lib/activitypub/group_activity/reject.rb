# frozen_string_literal: true

class ActivityPub::GroupActivity::Reject < ActivityPub::Activity
  def perform
    return reject_embedded_object! if @object['type'].present?
    reject_payload! if object_uri.nil?

    reject_from_uri!
  end

  private

  def reject_embedded_object!
    case @object['type']
    when 'Join'
      reject_embedded_join!
    when 'Create'
      reject_create_from_uri!
    else
      reject_payload!
    end
  end

  def reject_from_uri!
    reject_join_from_uri! || reject_create_from_uri! || reject_payload!
  end

  def reject_join_from_uri!
    membership_request = GroupMembershipRequest.find_by(group: @account, uri: object_uri)
    return false if membership_request.nil?

    RejectMembershipService.new.call(membership_request)
    true
  end

  def reject_create_from_uri!
    # If it's not a membership request, it could be a denied `Create`
    status = StatusFinder.new(object_uri, allow_activity: true).status
    return unless status.present? && status.group_id == @account.id

    RejectGroupStatusService.new.call(status)
    true
  rescue ActiveRecord::RecordNotFound
    false
  end

  def reject_embedded_join!
    target_account = account_from_uri(target_uri)
    return if target_account.nil? || !target_account.local?

    membership_request = GroupMembershipRequest.find_by(group: @account, account: target_account)
    return RejectMembershipService.new.call(membership_request) if membership_request.present?

    membership = GroupMembership.find_by(group: @account, account: target_account)
    membership&.destroy!
  end

  def target_uri
    @target_uri ||= value_or_id(@object['actor'])
  end
end
