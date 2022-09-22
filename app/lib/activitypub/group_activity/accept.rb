# frozen_string_literal: true

class ActivityPub::GroupActivity::Accept < ActivityPub::Activity
  def perform
    accept_join_from_uri! unless object_uri.nil?

    case @object['type']
    when 'Join'
      accept_embedded_join!
    end
  end

  private

  def accept_join_from_uri!
    membership_request = GroupMembershipRequest.find_by(group: @account, uri: object_uri) unless object_uri.nil?
    AuthorizeMembershipService.new.call(membership_request) if membership_request.present?

    # TODO: trigger stuff like fetching collections on first membership
  end

  def accept_embedded_join!
    target_account = account_from_uri(target_uri)
    return if target_account.nil? || !target_account.local?

    membership_request = GroupMembershipRequest.find_by(group: @account, account: target_account)
    AuthorizeMembershipService.new.call(membership_request) if membership_request.present?
  end

  def target_uri
    @target_uri ||= value_or_id(@object['actor'])
  end
end
