# frozen_string_literal: true

class ActivityPub::GroupActivity::Remove < ActivityPub::Activity
  def perform
    return if @json['target'].blank?

    case @json['target']
    when @account.wall_url
      remove_group_post!
    when @account.members_url
      remove_group_member!
    end
  end

  private

  def remove_group_post!
    return if object_uri.nil?

    target_status = status_from_uri(object_uri)
    return if target_status.nil? || target_status.group_id != @account.id

    if target_status.local?
      RejectGroupStatusService.new.call(target_status)
    else
      RemoveStatusService.new.call(target_status, redraft: false)
    end
  end

  def remove_group_member!
    return if object_uri.nil?

    target_account = account_from_uri(object_uri)
    return if target_account.nil?

    membership = @account.memberships.find_by(account: target_account)
    return if membership.nil?

    membership.destroy!
  end
end
